import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementStat extends StatelessWidget {
  const AchievementStat({super.key, required this.userAchievementModel});
  final AsyncValue<UserAchievementStatsModel?> userAchievementModel;

  @override
  Widget build(BuildContext context) {
    return userAchievementModel.when(
      data:
          (stats) => Row(
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
                    stats?.articlesRead.toString() ?? '0',
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
                    '${stats?.currentStreak ?? 0} ngày',
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
                    stats?.sortedAchievement.title ?? 'Người mới',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
      loading:
          () => Row(
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
                  const CircularProgressIndicator(),
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
                  const CircularProgressIndicator(),
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
                  const CircularProgressIndicator(),
                ],
              ),
            ],
          ),
      error:
          (error, stack) => Row(
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
                    '0',
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
                    '0 ngày',
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
                    'Người mới',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
