import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/bookmark/widgets/bookmark_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkList extends ConsumerWidget {
  const BookmarkList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider để auto rebuild khi có thay đổi
    final bookmarkViewModel = ref.watch(bookmarkProvider);
    final filteredBookmarks = bookmarkViewModel.filteredBookmarks;

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
                      ? Theme.of(context).cardTheme.color
                      : Theme.of(context).appBarTheme.backgroundColor,
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
                      hintText: 'Tìm kiếm theo tiêu đề, tóm tắt, nội dung...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        fontSize: 14,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onChanged: (value) {
                      // Sử dụng Provider để update search query
                      bookmarkViewModel.updateSearchQuery(value);
                    },
                  ),
                ),
                Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
        // Bookmark list
        Expanded(
          child:
              filteredBookmarks.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          bookmarkViewModel.searchQuery.isEmpty
                              ? Icons.bookmark_border
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          bookmarkViewModel.searchQuery.isEmpty
                              ? 'Chưa có bookmark nào'
                              : 'Không tìm thấy kết quả cho "${bookmarkViewModel.searchQuery}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = filteredBookmarks[index];
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
                              content: Text(
                                '${bookmark.title} được xóa thành công',
                              ),
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
