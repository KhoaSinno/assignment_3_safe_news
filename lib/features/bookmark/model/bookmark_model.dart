import 'package:hive/hive.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 0)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String link;

  @HiveField(4)
  final DateTime published;

  @HiveField(5)
  final String summary;

  @HiveField(6)
  final String htmlContent;

  @HiveField(7)
  final String plainTextContent;

  @HiveField(8)
  final DateTime bookmarkedAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.published,
    required this.summary,
    required this.htmlContent,
    required this.plainTextContent,
    required this.bookmarkedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'published': published.millisecondsSinceEpoch,
      'summary': summary,
      'htmlContent': htmlContent,
      'plainTextContent': plainTextContent,
      'bookmarkedAt': bookmarkedAt.millisecondsSinceEpoch,
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      link: json['link'] as String,
      published: DateTime.fromMillisecondsSinceEpoch(json['published'] as int),
      summary: json['summary'] as String,
      htmlContent: json['htmlContent'] as String,
      plainTextContent: json['plainTextContent'] as String,
      bookmarkedAt: DateTime.fromMillisecondsSinceEpoch(
        json['bookmarkedAt'] as int,
      ),
    );
  }
}
