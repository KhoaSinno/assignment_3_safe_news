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
          return const Center(child: Text('Không có bài viết nào.'));
        }
        return ListView.builder(
          itemCount: articles.length,
          padding: const EdgeInsets.only(),
          // Tối ưu performance với cacheExtent
          cacheExtent: 500.0,
          // Lazy loading với addAutomaticKeepAlives
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ArticleItem(
                article: article,
                key: ValueKey(article.id), // Stable key cho better performance
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi tải bài viết: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(articlesStreamProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
    );
  }
}
