import 'package:assignment_3_safe_news/constants/app_home_sort_time.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/article_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeArticleSortTime extends ConsumerWidget {
  const HomeArticleSortTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy giá trị sort time hiện tại từ provider
    final currentSortTime = ref.watch(sortTimeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentSortTime,
          items:
              getSortTimeValue().map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(getSortTimeLabel(value)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              // Cập nhật sort time trực tiếp thông qua provider
              updateSortTime(ref, newValue);
              print('Selected sort option (value: $newValue)');
            }
          },
        ),
      ),
    );
  }
}
