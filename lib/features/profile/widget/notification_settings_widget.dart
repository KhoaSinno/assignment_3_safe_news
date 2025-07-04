import 'package:assignment_3_safe_news/features/profile/widget/notice_settings_category_list.dart';
import 'package:assignment_3_safe_news/features/profile/widget/notice_settings_main_toggle.dart';
import 'package:assignment_3_safe_news/providers/notice_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/utils/news_notification_scheduler.dart';

class NotificationSettingsWidget extends ConsumerWidget {
  const NotificationSettingsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body:
          notificationSettings.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoticeSettingsMainToggle(
                    settings: notificationSettings,
                    notifier: notifier,
                  ),
                  const SizedBox(height: 20),

                  if (notificationSettings.isEnabled) ...[
                    NoticeSettingsCategoryList(
                      settings: notificationSettings,

                      notifier: notifier,
                    ),
                    const SizedBox(height: 20),
                    _buildManualCheckButton(context),
                    const SizedBox(height: 10),
                    _buildTestNotification(context, notifier),
                  ],
                ],
              ),
    );
  }

  Widget _buildManualCheckButton(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.refresh, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kiểm tra tin mới',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Kiểm tra tin tức mới ngay bây giờ',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đang kiểm tra tin tức mới...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Kiểm tra tin tức mới ngay lập tức
                await NewsNotificationScheduler().checkForNewNewsNow();

                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã kiểm tra xong!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kiểm tra'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotification(
    BuildContext context,
    NotificationSettingsNotifier notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.science, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test thông báo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Gửi thông báo thử nghiệm',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.sendTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã gửi thông báo test!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Test'),
            ),
          ],
        ),
      ),
    );
  }
}
