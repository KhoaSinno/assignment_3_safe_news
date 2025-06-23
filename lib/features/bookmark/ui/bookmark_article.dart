import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkArticle extends ConsumerStatefulWidget {
  const BookmarkArticle({super.key});

  @override
  _BookmarkArticleState createState() => _BookmarkArticleState();
}

class _BookmarkArticleState extends ConsumerState<BookmarkArticle> {
  @override
  Widget build(BuildContext context) {
    final bookmarkViewModel = ref.watch(bookmarkProvider);
    final bookmarks = bookmarkViewModel.bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmark',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: () {})],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                // bookmarks.removeAt(index);
                bookmarkViewModel.toggleBookmark(bookmarks[index]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${bookmark.title} được xóa thành công'),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        width: 112,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(bookmark.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookmark.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bookmark.title,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
