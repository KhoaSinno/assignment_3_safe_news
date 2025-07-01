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

// Provider để stream danh sách bài viết dựa trên category được chọn
final articlesStreamProvider = StreamProvider<List<ArticleModel>>((ref) {
  final selectedCategorySlug = ref.watch(
    selectedCategoryProvider,
  ); // Theo dõi category đang được chọn

  final textSearch = ref.watch(debouncedSearchProvider);

  final sortTime = ref.watch(sortTimeProvider);

  final articleRepository = ref.watch(articleRepositoryProvider);

  return articleRepository.fetchArticle(
    categorySlug: selectedCategorySlug!,
    title: textSearch,
    sortTime: sortTime,
  );
});

/// Helper function để cập nhật sort time
void updateSortTime(WidgetRef ref, String sortTime) {
  ref.read(sortTimeProvider.notifier).state = sortTime;
}
