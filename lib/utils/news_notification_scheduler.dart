import 'dart:async';
import 'dart:convert';
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Service để kiểm tra tin tức mới và gửi thông báo
class NewsNotificationScheduler {
  static final NewsNotificationScheduler _instance =
      NewsNotificationScheduler._internal();
  factory NewsNotificationScheduler() => _instance;
  NewsNotificationScheduler._internal();

  final NotificationService _notificationService = NotificationService();
  final ArticleItemRepository _articleRepository = ArticleItemRepository();
  Timer? _checkTimer;

  static const String _lastCheckKey = 'last_news_check';
  static const String _notificationHistoryKey = 'notification_history';

  /// Bắt đầu kiểm tra tin tức mới định kỳ
  void startPeriodicCheck({Duration interval = const Duration(hours: 1)}) {
    _checkTimer?.cancel();

    _checkTimer = Timer.periodic(interval, (timer) async {
      await _checkForNewNews();
    });
  }

  /// Dừng kiểm tra định kỳ
  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Kiểm tra tin tức mới ngay lập tức
  Future<void> checkForNewNewsNow() async {
    await _checkForNewNews();
  }

  /// Logic chính kiểm tra tin tức mới
  Future<void> _checkForNewNews() async {
    try {
      // Kiểm tra xem thông báo có được bật không
      final isNotificationEnabled =
          await _notificationService.areNotificationsEnabled();
      if (!isNotificationEnabled) return;

      // Lấy thời gian check lần cuối
      final prefs = await SharedPreferences.getInstance();
      final lastCheckString = prefs.getString(_lastCheckKey);
      final lastCheck =
          lastCheckString != null
              ? DateTime.parse(lastCheckString)
              : DateTime.now().subtract(const Duration(days: 1));

      // Lấy tin tức mới từ các categories đã subscribe
      final subscribedCategories = await _getSubscribedCategories();

      for (final category in subscribedCategories) {
        await _checkCategoryForNewNews(category, lastCheck);
      }

      // Cập nhật thời gian check
      await prefs.setString(_lastCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      // Log lỗi nếu cần thiết
    }
  }

  /// Lấy danh sách categories mà user đã subscribe
  Future<List<String>> _getSubscribedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = _notificationService.getNotificationCategories();
    final subscribedCategories = <String>[];

    for (final category in categories) {
      final isSubscribed = prefs.getBool('notifications_$category') ?? true;
      if (isSubscribed) {
        subscribedCategories.add(category);
      }
    }

    return subscribedCategories;
  }

  /// Kiểm tra tin tức mới cho một category cụ thể
  Future<void> _checkCategoryForNewNews(
    String category,
    DateTime lastCheck,
  ) async {
    try {
      // Lấy tin tức từ repository
      final articlesStream = _articleRepository.fetchArticle(
        categorySlug: category,
      );

      // Lấy snapshot đầu tiên từ stream
      final articles = await articlesStream.first;

      // Lọc tin tức mới (sau thời điểm check cuối)
      final newArticles =
          articles.where((article) {
            return article.published.isAfter(lastCheck);
          }).toList();

      // Gửi thông báo cho tin tức mới
      for (final article in newArticles.take(3)) {
        // Giới hạn 3 tin mới nhất
        await _sendNewsNotification(article, category);
      }
    } catch (e) {
      // Handle error
    }
  }

  /// Gửi thông báo cho một tin tức
  Future<void> _sendNewsNotification(
    ArticleModel article,
    String category,
  ) async {
    try {
      // Kiểm tra xem đã gửi thông báo cho tin này chưa
      if (await _isNotificationSent(article.link ?? '')) {
        return;
      }

      final categoryNames = {
        'breaking_news': 'Tin nóng',
        'sports': 'Thể thao',
        'technology': 'Công nghệ',
        'business': 'Kinh doanh',
        'entertainment': 'Giải trí',
        'health': 'Sức khỏe',
        'science': 'Khoa học',
      };

      final categoryName = categoryNames[category] ?? 'Tin tức';

      await _notificationService.showNotification(
        title: '🔥 $categoryName mới',
        body: article.title,
        payload: jsonEncode({
          'type': 'news_article',
          'article_url': article.link,
          'category': category,
        }),
      );

      // Lưu lịch sử đã gửi thông báo
      await _markNotificationSent(article.link ?? '');
    } catch (e) {
      // Handle error
    }
  }

  /// Kiểm tra xem đã gửi thông báo cho tin này chưa
  Future<bool> _isNotificationSent(String articleLink) async {
    if (articleLink.isEmpty) return true;

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_notificationHistoryKey) ?? '[]';
    final history = List<String>.from(jsonDecode(historyJson));

    return history.contains(articleLink);
  }

  /// Đánh dấu đã gửi thông báo cho tin này
  Future<void> _markNotificationSent(String articleLink) async {
    if (articleLink.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_notificationHistoryKey) ?? '[]';
    final history = List<String>.from(jsonDecode(historyJson));

    history.add(articleLink);

    // Giới hạn lịch sử (chỉ giữ 1000 tin gần nhất)
    if (history.length > 1000) {
      history.removeRange(0, history.length - 1000);
    }

    await prefs.setString(_notificationHistoryKey, jsonEncode(history));
  }

  /// Xóa lịch sử thông báo cũ (để cleanup)
  Future<void> clearOldNotificationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationHistoryKey);
    await prefs.remove(_lastCheckKey);
  }
}
