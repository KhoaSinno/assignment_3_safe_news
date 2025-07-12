import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:assignment_3_safe_news/providers/selected_badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadgeSelectionScreen extends ConsumerWidget {
  final UserAchievementStatsModel userStats;

  const BadgeSelectionScreen({super.key, required this.userStats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBadge = ref.watch(selectedBadgeProvider);

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: const Text('Chọn huy hiệu hiển thị'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref
                  .read(selectedBadgeProvider.notifier)
                  .clearSelectedBadge();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã về huy hiệu mặc định'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Mặc định'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn huy hiệu để hiển thị trên profile của bạn:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: userStats.unlockedAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = userStats.unlockedAchievements[index];
                  final isSelected = selectedBadge == achievement;

                  return BadgeSelectionItem(
                    achievement: achievement,
                    isSelected: isSelected,
                    onTap: () async {
                      await ref
                          .read(selectedBadgeProvider.notifier)
                          .selectBadge(achievement);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã chọn huy hiệu: ${achievement.title}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeSelectionItem extends StatelessWidget {
  final Achievement achievement;
  final bool isSelected;
  final VoidCallback onTap;

  const BadgeSelectionItem({
    super.key,
    required this.achievement,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? achievement.color : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected
                  ? achievement.color.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: achievement.color.withOpacity(0.1),
              child: SvgPicture.asset(
                achievement.assetPath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    achievement.icon,
                    size: 40,
                    color: achievement.color,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Badge Title
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? achievement.color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            // Selected indicator
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, color: achievement.color, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
