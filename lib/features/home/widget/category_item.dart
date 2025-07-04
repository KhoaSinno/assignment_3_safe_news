import 'package:assignment_3_safe_news/features/home/model/category_model.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/category_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryItem extends ConsumerWidget {
  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected, // Thêm isSelected vào constructor
  });

  final CategoryModel category;
  final bool isSelected; // Sử dụng isSelected được truyền vào

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      //  GestureDetector để xử lý onTap
      onTap: () {
        ref
            .read(selectedCategoryProvider.notifier)
            .update((state) => category.slug);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF2F2F7)),
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? null
                    : Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF555555)
                              : const Color(0xFFCAABB4),
                    ),
          ),
          child: Text(
            category.name,
            style: TextStyle(
              color:
                  isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 12,
              fontFamily: 'Aleo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
