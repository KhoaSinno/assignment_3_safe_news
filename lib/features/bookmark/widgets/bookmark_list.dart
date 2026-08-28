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
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardTheme.color
                      : Theme.of(context).appBarTheme.backgroundColor,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm trong danh sách đã lưu...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
                      bookmarkViewModel.updateSearchQuery(value);
                    },
                  ),
                ),
                if (bookmarkViewModel.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      bookmarkViewModel.updateSearchQuery('');
                    },
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
                        const SizedBox(height: 16),
                        Text(
                          bookmarkViewModel.searchQuery.isEmpty
                              ? 'Chưa có bài viết nào được lưu'
                              : 'Không tìm thấy kết quả cho "${bookmarkViewModel.searchQuery}"',
                          style: const TextStyle(
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
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(bookmark.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_outline, color: Colors.white, size: 22),
                                SizedBox(width: 6),
                                Text(
                                  'Xóa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onDismissed: (direction) {
                            final deletedBookmark = bookmark;
                            bookmarkViewModel.removeBookmark(bookmark.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã xóa "${bookmark.title}"',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                action: SnackBarAction(
                                  label: 'HOÀN TÁC',
                                  textColor: Colors.amberAccent,
                                  onPressed: () {
                                    bookmarkViewModel.addBookmark(deletedBookmark);
                                  },
                                ),
                              ),
                            );
                          },
                          child: BookmarkItem(bookmark: bookmark),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
