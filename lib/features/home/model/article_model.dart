import 'package:intl/intl.dart';

class ArticleModel {
  ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.published,
    this.link,
    this.isToxic,
    this.sentiment,
  });

  final String id;
  final String title;
  final String description;
  final DateTime published;
  final String? link;
  final bool? isToxic;
  final int? sentiment;

  factory ArticleModel.fromJson(Map<String, dynamic> json, String documentId) {
    return ArticleModel(
      id: documentId,
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? '',
      published: DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(json['published'] as String? ?? DateTime.now().toIso8601String()),
      link: json['link'] as String?,
      isToxic: json['is_toxic'] as bool?,
      sentiment: json['sentiment'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'published': published.toIso8601String(),
      'link': link,
      'is_toxic': isToxic,
      'sentiment': sentiment,
    };
  }
}