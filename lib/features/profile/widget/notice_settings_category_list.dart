import 'package:assignment_3_safe_news/features/profile/model/notification_settings_model.dart';
import 'package:assignment_3_safe_news/features/profile/widget/notice_settings_category_item.dart';
import 'package:assignment_3_safe_news/providers/notice_settings_provider.dart';
import 'package:flutter/material.dart';

class NoticeSettingsCategoryList extends StatelessWidget {
  const NoticeSettingsCategoryList({
    super.key,
    required this.settings,
    required this.notifier,
  });
  final NotificationSettings settings;
  final NotificationSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh mục thông báo',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...settings.categorySubscriptions.entries.map((entry) {
              return NoticeSettingsCategoryItem(
                category: entry.key,
                isSubscribed: entry.value,
                onChanged:
                    (value) =>
                        notifier.toggleCategorySubscription(entry.key, value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
