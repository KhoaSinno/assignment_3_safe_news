import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/category_item_viewmodel.dart';
import 'package:assignment_3_safe_news/providers/search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider cho ArticleItemRepository
final articleRepositoryProvider = Provider<ArticleItemRepository>((ref) {
  return ArticleItemRepository();
});

// Provider để stream danh sách bài viết dựa trên category được chọn
final articlesStreamProvider = StreamProvider<List<ArticleModel>>((ref) {
  final selectedCategorySlug = ref.watch(
    selectedCategoryProvider,
  ); // Theo dõi category đang được chọn

  final textSearch = ref.watch(
    debouncedSearchProvider,
  ); // Sử dụng debounced search
  
  final articleRepository = ref.watch(articleRepositoryProvider);

  return articleRepository.fetchArticle(
    categorySlug: selectedCategorySlug!,
    title: textSearch,
  );
});
