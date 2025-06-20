import 'package:assignment_3_safe_news/features/home/viewmodel/article_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/widget/article_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleList extends ConsumerWidget {
  const ArticleList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsyncValue = ref.watch(articlesStreamProvider);

    return articlesAsyncValue.when(
      data: (articles) {
        if (articles.isEmpty) {
          return Center(child: Text('Không có bài viết nào.'));
        }
        return ListView.builder(
          itemCount: articles.length,
          padding: EdgeInsets.only(top: 0),
          itemBuilder: (context, index) {
            final article = articles[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ArticleItem(article: article),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) =>
              Center(child: Text('Lỗi tải bài viết: $error')),
    );
  }
}
