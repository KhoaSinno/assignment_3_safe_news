import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/utils/logger.dart';
import 'package:assignment_3_safe_news/utils/article_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ArticleItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache cho summary và content với size limits
  static final Map<String, String> _summaryCache = {};
  static final Map<String, String> _contentCache = {};
  static final Map<String, DateTime> _cacheTimestamp = {};

  // Cache configuration
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50; // Giới hạn 50 items mỗi cache
  static const int _maxContentLength =
      50000; // Giới hạn độ dài content để cache

  Stream<List<ArticleModel>> fetchArticle({
    String categorySlug = 'all',
    String? title,
    String sortTime = 'AllTime',
  }) {
    Query query = _firestore.collection('news-crawler');
    // Query query = _firestore.collection('test_30_articles_new');

    // Áp dụng filter category trước
    if (categorySlug != 'all') {
      query = query.where('category', isEqualTo: categorySlug);
    }

    // Chỉ sắp xếp theo published (không filter ở Firestore vì published là string)
    query = query.orderBy('published', descending: true);

    return query.snapshots().map((snapshot) {
      List<ArticleModel> articles =
          snapshot.docs
              .map(
                (doc) => ArticleModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

      // Áp dụng filter thời gian ở client-side
      if (sortTime != 'AllTime') {
        DateTime filterDate = _getFilterDate(sortTime);
        articles =
            articles.where((article) {
              return article.published.isAfter(filterDate);
            }).toList();
      }

      // Áp dụng filter tìm kiếm title ở client-side
      if (title != null && title.isNotEmpty) {
        articles =
            articles.where((article) {
              return article.title.toLowerCase().contains(title.toLowerCase());
            }).toList();
      }

      return articles;
    });
  }

  /// Tính toán ngày để lọc dựa trên sortTime
  DateTime _getFilterDate(String sortTime) {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    switch (sortTime) {
      case 'Today':
        return startOfDay; // Từ 00:00:00 hôm nay
      case '3DaysAgo':
        return startOfDay.subtract(const Duration(days: 3)); // 3 ngày trước
      case '7DaysAgo':
        return startOfDay.subtract(const Duration(days: 7)); // 7 ngày trước
      case '1MonthAgo':
        return startOfDay.subtract(const Duration(days: 30)); // 30 ngày trước
      default:
        return DateTime(1970); // Trả về ngày rất xa trong quá khứ cho AllTime
    }
  }

  static String removeMarkdownBold(String text) {
    // Remove **...** at the start or anywhere in the text
    return text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1').trim();
  }

  static Future<String> summaryContentGemini(String content) async {
    if (content.isEmpty) {
      return "Nội dung trống, không thể tóm tắt.";
    }

    // Kiểm tra content quá dài - có thể gây memory issue
    if (content.length > _maxContentLength * 2) {
      // 100KB limit cho input
      content = content.substring(0, _maxContentLength * 2);
      print('Content truncated for Gemini API: ${content.length} chars');
    }

    // Tạo cache key từ content hash
    String cacheKey = content.hashCode.toString();

    // Check cache trước
    if (_summaryCache.containsKey(cacheKey)) {
      DateTime? cachedTime = _cacheTimestamp[cacheKey];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheExpiry) {
        print('Cache hit for summary: $cacheKey');
        return _summaryCache[cacheKey]!;
      } else {
        // Cache expired, remove it
        _summaryCache.remove(cacheKey);
        _cacheTimestamp.remove(cacheKey);
      }
    }

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
    );

    try {
      final prompt = [
        Content.text(
          'Tóm tắt nội dung sau bằng ngôn ngữ tiếng việt thành một đoạn ngắn (tối đa 300 từ), phong cách báo chí, mạch lạc dễ hiểu và cuốn hút. Chỉ trả về văn bản thuần túy, không sử dụng bất kỳ ký tự đặc biệt, markdown, hoặc định dạng nào: $content',
        ),
      ];

      final response = await model.generateContent(prompt);
      final rawText = response.text ?? "Không thể tạo tóm tắt.";
      final result = removeMarkdownBold(rawText);

      // Cache kết quả với size limit
      _cacheWithLimit(cacheKey, result, false);

      return result;
    } catch (e) {
      AppLogger.error('Error with Gemini API: $e');
      return "Lỗi khi gọi API tóm tắt.";
    }
  }

  /// Fetch article content with cache và size limit
  static Future<String> getContentWithCache(String? url) async {
    if (url == null || url.isEmpty) {
      return '<p>Không có link bài viết.</p>';
    }

    // Tạo cache key từ URL
    String cacheKey = url.hashCode.toString();

    // Check cache trước
    if (_contentCache.containsKey(cacheKey)) {
      DateTime? cachedTime = _cacheTimestamp['content_$cacheKey'];
      if (cachedTime != null &&
          DateTime.now().difference(cachedTime) < _cacheExpiry) {
        print('Cache hit for content: $cacheKey');
        return _contentCache[cacheKey]!;
      } else {
        // Cache expired, remove it
        _contentCache.remove(cacheKey);
        _cacheTimestamp.remove('content_$cacheKey');
      }
    }

    try {
      // Fetch content từ URL
      final content = await fetchArticleContent(url: url);

      // Truncate content nếu quá dài để tránh memory issues
      String processedContent = content;
      if (content.length > _maxContentLength) {
        processedContent = content.substring(0, _maxContentLength);
        print(
          'Content truncated for caching: ${content.length} -> ${processedContent.length} chars',
        );
      }

      // Cache kết quả với size limit
      _cacheWithLimit(cacheKey, processedContent, true);

      return processedContent;
    } catch (e) {
      AppLogger.error('Error fetching article content: $e');
      return '<p>Lỗi khi tải nội dung: $e</p>';
    }
  }

  /// Clear expired cache entries và log memory usage
  static void clearExpiredCache() {
    final statsBeforeClean = getCacheStats();
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamp.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiry) {
        expiredKeys.add(key);
      }
    });

    for (String key in expiredKeys) {
      _cacheTimestamp.remove(key);
      if (key.startsWith('content_')) {
        _contentCache.remove(key.substring(8));
      } else {
        _summaryCache.remove(key);
      }
    }

    if (expiredKeys.isNotEmpty) {
      final statsAfterClean = getCacheStats();
      print('Cleared ${expiredKeys.length} expired cache entries');
      print('Memory before cleanup: ${statsBeforeClean['totalMemoryKB']}KB');
      print('Memory after cleanup: ${statsAfterClean['totalMemoryKB']}KB');
    }

    // Nếu memory vẫn cao, clear thêm để tránh memory pressure
    final currentStats = getCacheStats();
    if (currentStats['totalMemoryKB'] > 5000) {
      // 5MB threshold
      print(
        'Memory still high (${currentStats['totalMemoryKB']}KB), clearing all cache',
      );
      clearAllCache();
    }
  }

  /// Cache kết quả với size limit và content length limit
  static void _cacheWithLimit(String key, String value, bool isContent) {
    // Kiểm tra độ dài content trước khi cache
    if (value.length > _maxContentLength) {
      print('Content too large to cache: ${value.length} chars');
      return;
    }

    final cache = isContent ? _contentCache : _summaryCache;
    final timestampKey = isContent ? 'content_$key' : key;

    // Nếu cache đầy, xóa item cũ nhất
    if (cache.length >= _maxCacheSize) {
      _removeOldestCacheEntry(isContent);
    }

    cache[key] = value;
    _cacheTimestamp[timestampKey] = DateTime.now();

    print(
      'Cached ${isContent ? 'content' : 'summary'} for key: $key (${cache.length}/$_maxCacheSize)',
    );
  }

  /// Xóa entry cũ nhất trong cache để giải phóng memory
  static void _removeOldestCacheEntry(bool isContent) {
    final cache = isContent ? _contentCache : _summaryCache;

    String? oldestKey;
    DateTime? oldestTime;

    _cacheTimestamp.forEach((key, time) {
      final isMatchingType =
          isContent ? key.startsWith('content_') : !key.startsWith('content_');
      if (isMatchingType &&
          (oldestTime == null || time.isBefore(oldestTime!))) {
        oldestTime = time;
        oldestKey = isContent ? key.substring(8) : key;
      }
    });

    if (oldestKey != null) {
      cache.remove(oldestKey);
      _cacheTimestamp.remove(isContent ? 'content_$oldestKey' : oldestKey);
      print(
        'Removed oldest ${isContent ? 'content' : 'summary'} cache entry: $oldestKey',
      );
    }
  }

  /// Get cache statistics for monitoring
  static Map<String, dynamic> getCacheStats() {
    final summaryMemory = _summaryCache.values.fold<int>(
      0,
      (sum, content) => sum + content.length,
    );
    final contentMemory = _contentCache.values.fold<int>(
      0,
      (sum, content) => sum + content.length,
    );

    return {
      'summaryCache': _summaryCache.length,
      'contentCache': _contentCache.length,
      'totalCacheEntries': _cacheTimestamp.length,
      'maxCacheSize': _maxCacheSize,
      'summaryMemoryKB': (summaryMemory / 1024).round(),
      'contentMemoryKB': (contentMemory / 1024).round(),
      'totalMemoryKB': ((summaryMemory + contentMemory) / 1024).round(),
    };
  }

  /// Force clear all cache (for debugging hoặc memory pressure)
  static void clearAllCache() {
    final stats = getCacheStats();
    _summaryCache.clear();
    _contentCache.clear();
    _cacheTimestamp.clear();
    print('All cache cleared. Previous stats: $stats');
  }
}
