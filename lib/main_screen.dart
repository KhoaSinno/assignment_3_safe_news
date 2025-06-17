import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/bottom_nav_provider.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_acticle.dart';
import 'package:assignment_3_safe_news/features/bookmark/ui/bookmark_article.dart';
import 'package:assignment_3_safe_news/features/profile/ui/profile_setting.dart';
import 'package:assignment_3_safe_news/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const HomeArticle(),
      const BookmarkArticle(),
      const ProfileSetting(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
