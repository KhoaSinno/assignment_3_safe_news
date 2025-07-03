import 'package:assignment_3_safe_news/features/profile/model/notification_settings.dart';
import 'package:assignment_3_safe_news/providers/notice_settings_provider.dart';
import 'package:flutter/material.dart';

class NoticeSettingsMainToggle extends StatelessWidget {
  final NotificationSettings settings;
  final NotificationSettingsNotifier notifier;

  const NoticeSettingsMainToggle({
    super.key,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông báo tin tức',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Nhận thông báo khi có tin tức mới',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Switch(
              value: settings.isEnabled,
              onChanged: notifier.toggleNotifications,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
