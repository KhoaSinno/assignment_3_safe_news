import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/category_item_viewmodel.dart';
import 'package:assignment_3_safe_news/providers/search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider cho ArticleItemRepository
final articleRepositoryProvider = Provider<ArticleItemRepository>((ref) {
  return ArticleItemRepository();
});

// Provider cho sort time
final sortTimeProvider = StateProvider<String>((ref) {
  return 'AllTime'; // Giá trị mặc định
});

// Provider cho sentiment filter: null (tất cả), 1 (tích cực), 0 (cảnh báo an toàn)
final sentimentFilterProvider = StateProvider<int?>((ref) {
  return null;
});

// Provider để stream danh sách bài viết dựa trên category được chọn
final articlesStreamProvider = StreamProvider<List<ArticleModel>>((ref) {
  final selectedCategorySlug = ref.watch(
    selectedCategoryProvider,
  ); // Theo dõi category đang được chọn

  final textSearch = ref.watch(debouncedSearchProvider);
  final sortTime = ref.watch(sortTimeProvider);
  final sentimentFilter = ref.watch(sentimentFilterProvider);
  final articleRepository = ref.watch(articleRepositoryProvider);

  return articleRepository.fetchArticle(
    categorySlug: selectedCategorySlug!,
    title: textSearch,
    sortTime: sortTime,
  ).map((articles) {
    if (sentimentFilter == null) return articles;
    return articles.where((a) => a.sentiment == sentimentFilter).toList();
  });
});

/// Helper function để cập nhật sort time
void updateSortTime(WidgetRef ref, String sortTime) {
  ref.read(sortTimeProvider.notifier).state = sortTime;
}
