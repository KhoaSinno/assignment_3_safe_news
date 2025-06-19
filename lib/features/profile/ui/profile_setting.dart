import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/theme_provider.dart';

class ProfileSetting extends ConsumerWidget {
  const ProfileSetting({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE9EEFA),
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
      ),
      body: Container(
        color: Colors.white,
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
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anh Khoa',
                    style: TextStyle(
                      color: const Color(0xFF231F20),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Chiến thần đọc sách',
                    style: TextStyle(
                      color: const Color(0xFF577BD9),
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
                      style: TextStyle(
                        color: const Color(0xFF8A8183),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '320',
                      style: TextStyle(
                        color: const Color(0xFF231F20),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Chuỗi đọc',
                      style: TextStyle(
                        color: const Color(0xFF8A8183),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '345 Days',
                      style: TextStyle(
                        color: const Color(0xFF231F20),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Hạng',
                      style: TextStyle(
                        color: const Color(0xFF8A8183),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '125',
                      style: TextStyle(
                        color: const Color(0xFF231F20),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Divider(color: const Color(0xFFE1DFE0), thickness: 1),
            const SizedBox(height: 16),
            Text(
              'Cài đặt',
              style: TextStyle(
                color: const Color(0xFF231F20),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Tài khoản của tôi',
                style: TextStyle(color: const Color(0xFF231F20), fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text(
                'Chính sách bảo mật',
                style: TextStyle(color: const Color(0xFF231F20), fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text(
                'Liên hệ',
                style: TextStyle(color: const Color(0xFF231F20), fontSize: 14),
              ),
              trailing: Icon(Icons.chevron_right),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(
                'Chế độ tối',
                style: TextStyle(color: const Color(0xFF231F20), fontSize: 14),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
