import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/bookmark/widgets/bookmark_list.dart';
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
    // Watch provider để auto-rebuild khi có thay đổi
    ref.watch(bookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmark',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Force refresh để sync lại data
              setState(() {});
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BookmarkList(),
      ),
    );
  }
}
