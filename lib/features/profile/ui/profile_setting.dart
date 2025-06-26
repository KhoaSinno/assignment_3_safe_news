import 'package:assignment_3_safe_news/features/authentication/ui/login_screen.dart';
import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/ui/contact_page.dart';
import 'package:assignment_3_safe_news/features/profile/ui/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/theme_provider.dart';

class ProfileSetting extends ConsumerWidget {
  const ProfileSetting({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = authViewModel.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hồ sơ cá nhân',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
        actions: [
          if (isLoggedIn) IconButton(icon: Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị profile hoặc login prompt
            if (isLoggedIn) ...[
              // Profile khi đã đăng nhập
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          authViewModel.user?.photoUrl != null
                              ? NetworkImage(authViewModel.user!.photoUrl!)
                              : NetworkImage("https://placehold.co/120x120"),
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      authViewModel.user?.name ??
                          authViewModel.user?.email ??
                          'User',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    ),
                    Text(
                      authViewModel.user?.email ?? '',
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
            ] else ...[
              // Login prompt khi chưa đăng nhập
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 80,
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa đăng nhập',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để truy cập đầy đủ tính năng',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Đăng nhập ngay'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

            // Chỉ hiển thị "Tài khoản của tôi" khi đã đăng nhập
            if (isLoggedIn)
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicy(),
                  ),
                );
              },
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactPage()),
                );
              },
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

            // Nút đăng xuất khi đã đăng nhập
            if (isLoggedIn) ...[
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  'Đăng xuất',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                onTap: () async {
                  // Hiển thị dialog xác nhận
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Xác nhận đăng xuất'),
                          content: Text(
                            'Bạn có chắc chắn muốn đăng xuất không?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true) {
                    try {
                      await authViewModel.signOut();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã đăng xuất thành công'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi khi đăng xuất: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
