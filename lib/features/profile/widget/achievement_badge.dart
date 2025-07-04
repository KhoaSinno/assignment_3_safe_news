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

    // ✅ Cache dimensions một lần
    final dimensions = _getDimensions(context);

    return userAchievementModel.when(
      data:
          (stats) => _buildUserProfile(
            context,
            authViewModel,
            dimensions,
            avatar:
                stats != null
                    ? _buildAchievementAvatar(
                      stats,
                      dimensions.avatarRadius,
                      dimensions.iconSize,
                    )
                    : Icon(
                      Icons.person,
                      size: dimensions.fallbackIconSize,
                      color: Theme.of(context).primaryColor,
                    ),
            displayName:
                stats?.displayName ?? authViewModel.user?.name ?? 'User',
          ),
      loading:
          () => _buildUserProfile(
            context,
            authViewModel,
            dimensions,
            avatar: const CircularProgressIndicator(),
            displayName: authViewModel.user?.name ?? 'Đang tải...',
          ),
      error:
          (error, stack) => _buildUserProfile(
            context,
            authViewModel,
            dimensions,
            avatar: ClipOval(
              child: Icon(
                Icons.account_circle,
                size: dimensions.avatarRadius * 1.8,
                color: Theme.of(context).primaryColor,
              ),
            ),
            displayName: authViewModel.user?.name ?? 'User',
          ),
    );
  }

  // ✅ Helper method để giảm duplicate code
  Widget _buildUserProfile(
    BuildContext context,
    AuthViewModel authViewModel,
    _Dimensions dimensions, {
    required Widget avatar,
    required String displayName,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✅ Tối ưu layout
        children: [
          CircleAvatar(
            radius: dimensions.avatarRadius,
            backgroundColor: Colors.white,
            child: avatar,
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: dimensions.fontSize),
            textAlign: TextAlign.center,
          ),
          if (authViewModel.user?.email != null &&
              authViewModel.user!.email.isNotEmpty)
            Text(
              authViewModel.user?.email ?? '',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontSize: dimensions.emailFontSize,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  // ✅ Cache dimensions
  _Dimensions _getDimensions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth < 400 ? 80.0 : 100.0;
    return _Dimensions(
      avatarRadius: avatarRadius,
      iconSize: avatarRadius * 1.2,
      fallbackIconSize: avatarRadius * 1.4,
      fontSize: screenWidth < 400 ? 20.0 : 24.0,
      emailFontSize: screenWidth < 400 ? 12.0 : 14.0,
    );
  }

  Widget _buildAchievementAvatar(
    UserAchievementStatsModel stats,
    double avatarRadius,
    double iconSize,
  ) {
    return ClipOval(
      child: SvgPicture.asset(
        stats.sortedAchievement.assetPath,
        width: avatarRadius * 2,
        height: avatarRadius * 2,
        fit: BoxFit.cover,
        placeholderBuilder:
            (context) => _buildPlaceholder(stats, avatarRadius, iconSize),
        // ✅ Thêm error handling cho SVG loading
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            'SVG loading error for ${stats.sortedAchievement.assetPath}: $error',
          );
          return _buildPlaceholder(stats, avatarRadius, iconSize);
        },
      ),
    );
  }

  Widget _buildPlaceholder(
    UserAchievementStatsModel stats,
    double avatarRadius,
    double iconSize,
  ) {
    return Container(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: stats.sortedAchievement.color.withValues(alpha: 0.1),
      ),
      child: Icon(
        stats.sortedAchievement.icon,
        size: iconSize,
        color: stats.sortedAchievement.color,
      ),
    );
  }
}

class _Dimensions {
  final double avatarRadius;
  final double iconSize;
  final double fallbackIconSize;
  final double fontSize;
  final double emailFontSize;

  _Dimensions({
    required this.avatarRadius,
    required this.iconSize,
    required this.fallbackIconSize,
    required this.fontSize,
    required this.emailFontSize,
  });
}
