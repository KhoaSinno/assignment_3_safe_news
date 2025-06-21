import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/theme_provider.dart';
import 'package:assignment_3_safe_news/features/debug/debug_page.dart';

class ProfileSetting extends ConsumerWidget {
  const ProfileSetting({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      "https://placehold.co/120x120",
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anh Khoa',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  ),
                  Text(
                    'Chiến thần đọc sách',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Báo đã đọc',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    Text(
                      '320',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Chuỗi đọc',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    Text(
                      '345 Days',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Hạng',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    Text(
                      '125',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: Theme.of(context).dividerColor, thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Cài đặt',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Tài khoản của tôi',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text(
                'Chính sách bảo mật',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text(
                'Liên hệ',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(
                'Chế độ tối',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.bug_report),
              title: Text(
                'Debug - Weather & Location',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DebugPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
