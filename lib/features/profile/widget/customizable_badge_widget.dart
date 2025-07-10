import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:assignment_3_safe_news/features/profile/widget/badge_selection_screen.dart';
import 'package:assignment_3_safe_news/providers/selected_badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomizableBadgeWidget extends ConsumerWidget {
  final UserAchievementStatsModel userStats;
  final double avatarRadius;
  final double iconSize;

  const CustomizableBadgeWidget({
    super.key,
    required this.userStats,
    required this.avatarRadius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBadge = ref.watch(selectedBadgeProvider);

    // Sử dụng badge đã chọn hoặc badge mặc định (priority cao nhất)
    final displayBadge = selectedBadge ?? userStats.sortedAchievement;

    return GestureDetector(
      onTap: () {
        // Chỉ cho phép thay đổi nếu có nhiều hơn 1 badge
        if (userStats.unlockedAchievements.length > 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BadgeSelectionScreen(userStats: userStats),
            ),
          );
        }
      },
      child: Stack(
        children: [
          // Badge Avatar
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: SvgPicture.asset(
                displayBadge.assetPath,
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: avatarRadius * 2,
                    height: avatarRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: displayBadge.color.withOpacity(0.1),
                    ),
                    child: Icon(
                      displayBadge.icon,
                      size: iconSize,
                      color: displayBadge.color,
                    ),
                  );
                },
              ),
            ),
          ),

          // Edit icon nếu có nhiều badge để chọn
          if (userStats.unlockedAchievements.length > 1)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
