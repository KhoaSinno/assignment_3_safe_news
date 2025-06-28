import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/utils/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ArticleItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<List<ArticleModel>> fetchArticle({
    String categorySlug = 'all',
    String? title,
  }) {
    Query query = _firestore.collection('news-crawler');

    // Áp dụng filter category trước
    if (categorySlug != 'all') {
      query = query.where('category', isEqualTo: categorySlug);
    }

    // Sắp xếp theo published
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

  static String removeMarkdownBold(String text) {
    // Remove **...** at the start or anywhere in the text
    return text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1').trim();
  }

  static Future<String> summaryContentGemini(String content) async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
    );

    if (content.isEmpty) {
      return "Nội dung trống, không thể tóm tắt.";
    }
    try {
      final prompt = [
        Content.text(
          'Tóm tắt nội dung sau bằng ngôn ngữ tiếng việt thành một đoạn ngắn, phong cách báo chí, mạch lạc dễ hiểu và cuốn hút. Chỉ trả về văn bản thuần túy, không sử dụng bất kỳ ký tự đặc biệt, markdown, hoặc định dạng nào: $content',
        ),
      ];

      final response = await model.generateContent(prompt);
      final rawText = response.text ?? "Không thể tạo tóm tắt.";
      return removeMarkdownBold(rawText);
    } catch (e) {
      AppLogger.error('Error with Gemini API: $e');
      return "Lỗi khi gọi API tóm tắt.";
    }
  }
}
