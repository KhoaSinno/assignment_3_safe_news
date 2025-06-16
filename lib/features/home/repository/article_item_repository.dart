import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

class ArticleItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ArticleModel>> fetchArticle({String categorySlug = 'all'}) {
    Query query = _firestore.collection('news-crawler');
    if (categorySlug != 'all') {
      query = query.where('category', isEqualTo: categorySlug);
    }

    query = query.orderBy('published', descending: true);

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => ArticleModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
    );
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
          'Tóm tắt nội dung sau bằng ngôn ngữ tiếng việt thành một đoạn ngắn, phong cách báo trí, mạch lạc dễ hiểu và cuốn hút: $content',
        ),
      ];

      final response = await model.generateContent(prompt);

      return response.text ?? "Không thể tạo tóm tắt.";
    } catch (e) {
      print('Error with Gemini API: $e');
      return "Lỗi khi gọi API tóm tắt.";
    }
  }
}
