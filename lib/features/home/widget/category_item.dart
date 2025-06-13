import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...Categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: buildCategoryChip(
                    category['name']!,
                    isSelected: category['slug'] == AppCategory.tinMoiNhat,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
