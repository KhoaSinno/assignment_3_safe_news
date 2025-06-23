import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:assignment_3_safe_news/features/bookmark/repository/bookmark_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkViewModel extends ChangeNotifier {
  final BookmarkRepository _repository = BookmarkRepository.instance;

  // Chỉ kiểm tra bookmark status - không duplicate logic
  bool isBookmarked(String articleId) {
    return _repository.isBookmarked(articleId);
  }

  // Wrapper cho addBookmark với notification
  Future<void> addBookmark(BookmarkModel bookmark) async {
    await _repository.addBookmark(bookmark);
    notifyListeners(); // Chỉ notify để update UI
  }

  // Wrapper cho removeBookmark với notification
  Future<void> removeBookmark(String articleId) async {
    await _repository.removeBookmark(articleId);
    notifyListeners(); // Chỉ notify để update UI
  }

  // Wrapper cho getBookmarks - không duplicate logic
  List<BookmarkModel> get bookmarks => _repository.getBookmarks();

  // Helper method cho toggle
  Future<void> toggleBookmark(BookmarkModel bookmark) async {
    if (isBookmarked(bookmark.id)) {
      await removeBookmark(bookmark.id);
    } else {
      await addBookmark(bookmark);
    }
  }
}

// Provider - đơn giản hơn
final bookmarkProvider = ChangeNotifierProvider<BookmarkViewModel>((ref) {
  return BookmarkViewModel();
});
