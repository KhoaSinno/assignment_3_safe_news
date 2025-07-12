import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/bookmark/widgets/bookmark_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookmarkArticle extends ConsumerStatefulWidget {
  const BookmarkArticle({super.key});

  @override
  ConsumerState<BookmarkArticle> createState() => _BookmarkArticleState();
}

class _BookmarkArticleState extends ConsumerState<BookmarkArticle> {
  @override
  Widget build(BuildContext context) {
    // Watch provider để auto-rebuild khi có thay đổi
    ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        // Border radius and shadow for the AppBar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        shadowColor: Colors.black.withOpacity(0.5),
        title: Text(
          'Bookmark',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Force refresh để sync lại data
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const BookmarkList(),
      ),
    );
  }
}
