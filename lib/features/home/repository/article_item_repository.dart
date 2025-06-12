import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<List<ArticleModel>> fetchArticles() async {
  //   try {
  //     final snapshot = await _firestore.collection('news').get();
  //     return snapshot.docs
  //         .map((doc) => ArticleModel.fromJson(doc.data()))
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching articles: $e');
  //     rethrow;
  //   }
  // }
  Future<List<ArticleModel>> fetchArticle() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('articles').get();
      return querySnapshot.docs
          .map(
            (doc) => ArticleModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching articles: $e');
      return [];
    }
  }
  // Future<void> addArticle(ArticleModel article) async {
  //   try {
  //     await _firestore.collection('articles').add(article.toJson());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> updateArticle(String id, ArticleModel article) async {
    try {
      await _firestore.collection('articles').doc(id).update(article.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteArticle(String id) async {
    try {
      await _firestore.collection('articles').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
