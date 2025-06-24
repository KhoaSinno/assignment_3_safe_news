import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:assignment_3_safe_news/features/bookmark/repository/bookmark_repository.dart';
import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/bookmark/widgets/bookmark_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkList extends ConsumerWidget {
  const BookmarkList({super.key, required this.bookmarks});
  final List<BookmarkModel> bookmarks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkViewModel = ref.watch(bookmarkProvider);
    final BookmarkRepository _repository = BookmarkRepository.instance;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFCAABB4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x3F000000),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm',
                      hintStyle: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.black54,
                        fontSize: 16,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                    ),
                    onChanged: (value) => {_repository.searchBookmarks(value)},
                  ),
                ),
                Icon(
                  Icons.search,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        // Bookmark list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return Dismissible(
                key: Key(bookmark.title),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  bookmarkViewModel.removeBookmark(bookmark.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${bookmark.title} được xóa thành công'),
                    ),
                  );
                },
                child: BookmarkItem(bookmark: bookmark),
              );
            },
          ),
        ),
      ],
    );
  }
}
