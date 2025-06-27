import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AchievementBadge extends ConsumerWidget {
  const AchievementBadge({super.key, required this.userAchievementModel});
  final AsyncValue<UserAchievementStatsModel?> userAchievementModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);

    // Responsive avatar size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth < 400 ? 80.0 : 100.0;
    final iconSize = avatarRadius * 1.2;
    final fallbackIconSize = avatarRadius * 1.4;

    return userAchievementModel.when(
      data:
          (stats) => Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: Colors.white,
                      child:
                          stats != null
                              ? ClipOval(
                                child: SvgPicture.asset(
                                  stats.sortedAchievement.assetPath,
                                  width: avatarRadius * 2, // Full diameter
                                  height: avatarRadius * 2, // Full diameter
                                  fit:
                                      BoxFit.cover, // Fill toàn bộ CircleAvatar
                                  placeholderBuilder:
                                      (context) => Container(
                                        width: avatarRadius * 2,
                                        height: avatarRadius * 2,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: stats.sortedAchievement.color
                                              .withOpacity(0.1),
                                        ),
                                        child: Icon(
                                          stats.sortedAchievement.icon,
                                          size: iconSize,
                                          color: stats.sortedAchievement.color,
                                        ),
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: fallbackIconSize,
                                color: Theme.of(context).primaryColor,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  stats?.displayName ?? authViewModel.user?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 20 : 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  authViewModel.user?.email ?? '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      loading:
          () => Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Theme.of(context).cardColor,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 8),
                Text(
                  authViewModel.user?.name ?? 'Đang tải...',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 20 : 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  authViewModel.user?.email ?? '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
      error:
          (error, stack) => Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Theme.of(context).cardColor,
                  child: ClipOval(
                    child: Icon(
                      Icons.account_circle,
                      size:
                          avatarRadius * 1.8, // Slightly larger for better fill
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authViewModel.user?.name ?? 'User',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 20 : 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  authViewModel.user?.email ?? '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: screenWidth < 400 ? 12 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }
}
