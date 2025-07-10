import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:assignment_3_safe_news/features/profile/widget/user_profile_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementBadge extends ConsumerWidget {
  const AchievementBadge({super.key, required this.userAchievementModel});
  final AsyncValue<UserAchievementStatsModel?> userAchievementModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: UserProfileSection(userAchievementModel: userAchievementModel),
    );
  }
}
