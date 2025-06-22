import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class BookmarkModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Method to convert BookmarkModel to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
