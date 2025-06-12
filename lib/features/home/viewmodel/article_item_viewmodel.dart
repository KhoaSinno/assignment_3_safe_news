import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final articleItemViewModelProvider = ChangeNotifierProvider(
  (ref) => ArticleItemViewModel(),
);

class ArticleItemViewModel extends ChangeNotifier {
  ArticleItemRepository _articleItemRepository = ArticleItemRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ArticleModel? _article;
  ArticleModel? get article => _article;

  Future<List<ArticleModel>> fetchArticle() async {
    try {
      List<ArticleModel> articles = await _articleItemRepository.fetchArticle();
      return articles;
    } catch (e) {
      rethrow;
    }
  }
}
