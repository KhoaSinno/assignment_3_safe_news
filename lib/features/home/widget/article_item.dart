import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:assignment_3_safe_news/features/home/ui/detail_article.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleItem extends StatelessWidget {
  const ArticleItem({super.key, required this.article});
  final article;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailArticle(article: article)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(article.imageUrl),
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
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF231F20),
                    fontSize: 18,
                    fontFamily: 'Aleo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getNameFromCategory(article.category),
                  style: const TextStyle(
                    color: Color(0xFF6D6265),
                    fontSize: 14,
                    fontFamily: 'Merriweather',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  // Wrap the Text widget with SizedBox for full width
                  width: double.infinity,
                  child: Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(article.published).toString(),
                    textAlign:
                        TextAlign
                            .end, // This will now align the text to the right
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6D6265),
                      fontSize: 14,
                      fontFamily: 'Merriweather',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
