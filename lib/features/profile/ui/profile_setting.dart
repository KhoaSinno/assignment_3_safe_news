import 'package:assignment_3_safe_news/features/authentication/ui/login_screen.dart';
import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/ui/contact_page.dart';
import 'package:assignment_3_safe_news/features/profile/ui/privacy_policy.dart';
import 'package:assignment_3_safe_news/features/profile/widget/achievement_badge.dart';
import 'package:assignment_3_safe_news/features/profile/widget/achievement_stat.dart';
import 'package:assignment_3_safe_news/features/profile/widget/badge_selection_screen.dart';
import 'package:assignment_3_safe_news/features/profile/widget/notification_settings_widget.dart';
import 'package:assignment_3_safe_news/features/profile/widget/user_ranking_widget.dart';
import 'package:assignment_3_safe_news/providers/user_stats_provider.dart';
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
    final userAchievementModel = ref.watch(userStatsProvider);

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = authViewModel.user != null;

    return Scaffold(
      appBar: AppBar(
        // Border radius and shadow for the AppBar
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        title: Text(
          'Hồ sơ cá nhân',
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Achievement-based Profile
              if (isLoggedIn) ...[
                SizedBox(
                  width: double.infinity,
                  child: AchievementBadge(
                    userAchievementModel: userAchievementModel,
                  ),
                ),
                const SizedBox(height: 16),
                // User Ranking Card
                const UserRankingWidget(),
                const SizedBox(height: 16),
                // Achievement Stats Row
                AchievementStat(userAchievementModel: userAchievementModel),
              ] else ...[
                const SizedBox(height: 24),
                // Login prompt khi chưa đăng nhập
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.7),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 14, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
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
              if (isLoggedIn) ...[
                // Thêm option chọn badge
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: Text(
                    'Chọn huy hiệu hiển thị',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Chỉ cho phép chọn badge khi có dữ liệu achievement
                    userAchievementModel.when(
                      data: (stats) {
                        if (stats != null &&
                            stats.unlockedAchievements.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      BadgeSelectionScreen(userStats: stats),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chưa có badge nào để chọn'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      loading: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đang tải dữ liệu...'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      },
                      error: (error, stack) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lỗi khi tải dữ liệu achievement'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],

              // Notification Settings - always show
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(
                  'Cài đặt thông báo',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsWidget(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(
                  'Chính sách bảo mật',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right),
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
                leading: const Icon(Icons.contact_mail),
                title: Text(
                  'Liên hệ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactPage(),
                    ),
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
                  leading: const Icon(Icons.logout, color: Colors.red),
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
                            title: const Text('Xác nhận đăng xuất'),
                            content: const Text(
                              'Bạn có chắc chắn muốn đăng xuất không?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
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
                            const SnackBar(
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
      ),
    );
  }
}
