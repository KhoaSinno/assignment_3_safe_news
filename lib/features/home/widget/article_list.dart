import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/article_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/widget/article_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleList extends ConsumerWidget {
  const ArticleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleProvider = ref.watch(articleItemViewModelProvider);

    return Expanded(
      child: StreamBuilder<List<ArticleModel>>(
        stream: articleProvider.fetchArticle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No articles found'));
          }
          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            padding: EdgeInsets.only(top: 0),
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: ArticleItem(articles: articles[index]),
                ),
          );
        },
      ),
    );
  }
}
