import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/category_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/widget/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCateProvider = ref.watch(selectedCategoryProvider);
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
              ...categories.entries.map((entry) {
                return CategoryItem(category : entry.value, isSelected: selectedCateProvider == entry.key,);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
