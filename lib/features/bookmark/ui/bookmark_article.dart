import 'package:flutter/material.dart';

class BookmarkArticle extends StatefulWidget {
  const BookmarkArticle({Key? key}) : super(key: key);

  @override
  _BookmarkArticleState createState() => _BookmarkArticleState();
}

class _BookmarkArticleState extends State<BookmarkArticle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Danh sách bài viết đã đánh dấu',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Placeholder for bookmarked articles
          Text(
            'Chức năng này sẽ sớm được cập nhật.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
