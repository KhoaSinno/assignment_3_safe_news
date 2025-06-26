import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookmarkRepository {
  static const String _boxName = 'bookmarks';
  static BookmarkRepository? _instance;
  Box<BookmarkModel>? _bookmarkBox;
  bool _isInitialized = false;

  // Singleton pattern
  static BookmarkRepository get instance {
    _instance ??= BookmarkRepository._internal();
    return _instance!;
  }

  BookmarkRepository._internal();

  // Lazy initialize Firestore to avoid Firebase not initialized error
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> init() async {
    if (_isInitialized) return;

    // Check if adapter is already registered to avoid duplicate registration
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(BookmarkModelAdapter());
    }
    _bookmarkBox = await Hive.openBox<BookmarkModel>(_boxName);
    _isInitialized = true;
  }

  // Search local realtime in _bookmarkBox with title or description
  List<BookmarkModel> searchBookmarks(String query) {
    if (!_isInitialized) {
      throw StateError(
        'BookmarkRepository chưa được khởi tạo. Hãy gọi init() trước.',
      );
    }

    if (query.isEmpty) return getBookmarks();

    final lowerQuery = query.toLowerCase();
    return _safeBookmarkBox.values
        .where(
          (bookmark) =>
              bookmark.plainTextContent.toLowerCase().contains(lowerQuery) ||
              bookmark.title.toLowerCase().contains(lowerQuery) ||
              bookmark.summary.toLowerCase().contains(lowerQuery),
        )
        .toList()
      ..sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
  }

  // Getter với kiểm tra initialization
  Box<BookmarkModel> get _safeBookmarkBox {
    if (_bookmarkBox == null || !_isInitialized) {
      throw StateError(
        'BookmarkRepository chưa được khởi tạo. Hãy gọi init() trước.',
      );
    }
    return _bookmarkBox!;
  }

  final user = FirebaseAuth.instance.currentUser;
  Future<void> addBookmark(BookmarkModel bookmark) async {
    // Add to Hive
    await _safeBookmarkBox.put(bookmark.id, bookmark);

    // Sync to Firebase if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(bookmark.id)
          .set(bookmark.toJson());
    }
  }

  Future<void> removeBookmark(String id) async {
    // Remove from Hive
    await _safeBookmarkBox.delete(id);

    // Remove from Firebase if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(id)
          .delete();
    }
  }

  List<BookmarkModel> getBookmarks() {
    // Cascade Operator
    return _safeBookmarkBox.values.toList()
      ..sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
  }

  Future<void> refreshBookmarks() async {
    // Đồng bộ từ Firebase
    await syncFromFirebase();
  }

  bool isBookmarked(String id) {
    return _safeBookmarkBox.containsKey(id);
  }

  // Đồng bộ từ Firebase
  Future<void> syncFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('bookmarks')
              .get();

      // Xóa bookmark local cũ
      await _safeBookmarkBox.clear();

      // Thêm bookmark từ Firebase
      for (var doc in snapshot.docs) {
        final bookmark = BookmarkModel.fromJson(doc.data());
        await _safeBookmarkBox.put(bookmark.id, bookmark);
      }
    } catch (e) {
      print('Error syncing from Firebase: $e');
    }
  }

  // Đồng bộ lên Firebase
  Future<void> syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final localBookmarks = getBookmarks();

      for (var bookmark in localBookmarks) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .doc(bookmark.id)
            .set(bookmark.toJson());
      }
    } catch (e) {
      print('Error syncing to Firebase: $e');
    }
  }

  // Lắng nghe thay đổi real-time
  Stream<List<BookmarkModel>> watchBookmarks() {
    return Stream.fromFuture(Future.value(getBookmarks()));
  }

  void dispose() {
    _bookmarkBox?.close();
  }
}
