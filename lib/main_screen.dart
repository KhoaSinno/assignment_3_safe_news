import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/bottom_nav_provider.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_article.dart';
import 'package:assignment_3_safe_news/features/bookmark/ui/bookmark_article.dart';
import 'package:assignment_3_safe_news/features/profile/ui/profile_setting.dart';
import 'package:assignment_3_safe_news/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  // Đảm bảo app chạy full screen edge-to-edge
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const HomeArticle(),
      const BookmarkArticle(),
      const ProfileSetting(),
    ];

    // Sử dụng MediaQuery để loại bỏ padding system
    return MediaQuery.removePadding(
      context: context,
      child: Scaffold(
        extendBody: true, // Mở rộng body đến edge
        extendBodyBehindAppBar: true, // Mở rộng body phía sau app bar
        resizeToAvoidBottomInset: false, // Không resize khi keyboard xuất hiện
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: const CustomBottomNavBar(),
      ),
    );
  }
}
