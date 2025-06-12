class ArticleModel {
  ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    // required this.imageUrl,
    // required this.author,
    required this.published,
    this.link,
    this.isToxic,
    this.sentiment,
  });

  final String id;
  final String title;
  final String description;
  // final String imageUrl;
  // final String author;
  final DateTime published;
  final String? link;
  bool? isToxic;
  int? sentiment;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      published: DateTime.parse(json['published'] as String),
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
      // 'imageUrl': imageUrl,
      // 'author': author,
      'published': published.toIso8601String(),
      'link': link,
      'is_toxic': isToxic,
      'sentiment': sentiment,
    };
  }
}
