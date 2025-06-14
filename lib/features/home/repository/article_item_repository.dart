import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Future<List<ArticleModel>> fetchArticle() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await _firestore.collection('news-crawler').get();
  //     print('QuerySnapshot docs: ${querySnapshot.docs.length} documents');
  //     return querySnapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>?;
  //       print('Doc data: $data');
  //       try {
  //         return ArticleModel.fromJson(data ?? {}, doc.id);
  //       } catch (e) {
  //         print('Error parsing doc ${doc.id}: $e');
  //         // Trả về model với published mặc định nếu parse thất bại
  //         return ArticleModel(
  //           id: doc.id,
  //           title: data?['title'] as String? ?? 'No title',
  //           description: data?['description'] as String? ?? '',
  //           published: DateTime.now(), // Giá trị mặc định
  //           link: data?['link'] as String?,
  //           imageUrl: data?['image_url'] as String? ?? 'https://placehold.co/150x150',
  //           category: data?['category'] as String? ?? '',
  //           isToxic: data?['is_toxic'] as bool?,
  //           sentiment: data?['sentiment'] as int?,
  //         );
  //       }
  //     }).toList();
  //   } catch (e) {
  //     print('Error fetching articles: $e');
  //     return [];
  //   }
  // }
  // Future<void> addArticle(ArticleModel article) async {
  //   try {
  //     await _firestore.collection('articles').add(article.toJson());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> updateArticle(String id, ArticleModel article) async {
  //   try {
  //     await _firestore.collection('News').doc(id).update(article.toJson());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> deleteArticle(String id) async {
  //   try {
  //     await _firestore.collection('News').doc(id).delete();
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
