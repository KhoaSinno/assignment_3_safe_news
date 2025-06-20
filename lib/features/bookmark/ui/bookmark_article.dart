import 'package:flutter/material.dart';

class BookmarkArticle extends StatefulWidget {
  const BookmarkArticle({super.key});

  @override
  _BookmarkArticleState createState() => _BookmarkArticleState();
}

class _BookmarkArticleState extends State<BookmarkArticle> {
  final List<Map<String, String>> bookmarks = [
    {
      'title': 'How to Setup Your Workspace',
      'category': 'Interior',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title':
          'Discovering Hidden Gems: 8 Off-The-Beaten-Path Travel Destinations',
      'category': 'Travel',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title': 'Exploring the World\'s Best Beaches: Top 5 Picks',
      'category': 'Travel',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title': 'Travel Destinations That Won\'t Break the Bank',
      'category': 'Travel',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title': 'How Working Remotely Will Make You More Happy',
      'category': 'Business',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title': 'Destinations for Authentic Local Experiences',
      'category': 'Business',
      'image': 'https://placehold.co/112x80',
    },
    {
      'title': 'A Guide to Seasonal Gardening',
      'category': 'Travel',
      'image': 'https://placehold.co/112x80',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              key: Key(bookmark['title']!),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                bookmarks.removeAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${bookmark['title']} removed')),
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
                            image: NetworkImage(bookmark['image']!),
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
                              bookmark['title']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bookmark['category']!,
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
