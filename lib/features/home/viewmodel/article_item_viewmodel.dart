import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/category_item_viewmodel.dart';
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

  final articleRepository = ref.watch(articleRepositoryProvider);
  return articleRepository.fetchArticle(categorySlug: selectedCategorySlug!);
});

// My code
// final articleItemViewModelProvider = ChangeNotifierProvider(
//   (ref) => ArticleItemViewModel(),
// );

// class ArticleItemViewModel extends ChangeNotifier {
//   final ArticleItemRepository _articleItemRepository = ArticleItemRepository();
//   ArticleModel? _article;
//   ArticleModel? get article => _article;

//   Stream<List<ArticleModel>> fetchArticle() {
//     try {
//       return _articleItemRepository.fetchArticle();
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
