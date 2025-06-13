import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleItem extends StatelessWidget {
  const ArticleItem({super.key, required this.articles});
  final articles;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(articles.imageUrl),
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
                articles.title,
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
                getNameFromCategory(articles.category),
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
                  ).format(articles.published).toString(),
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
    );
  }
}
