import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:assignment_3_safe_news/features/profile/widget/customizable_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileSection extends ConsumerWidget {
  final AsyncValue<UserAchievementStatsModel?> userAchievementModel;

  const UserProfileSection({super.key, required this.userAchievementModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);

    // Cache dimensions một lần
    final dimensions = _getDimensions(context);

    return userAchievementModel.when(
      data:
          (stats) => _buildUserProfile(
            context,
            authViewModel,
            dimensions,
            stats: stats,
          ),
      loading: () => _buildLoadingProfile(context, authViewModel, dimensions),
      error:
          (error, stack) =>
              _buildErrorProfile(context, authViewModel, dimensions),
    );
  }

  Widget _buildUserProfile(
    BuildContext context,
    AuthViewModel authViewModel,
    _Dimensions dimensions, {
    UserAchievementStatsModel? stats,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar với badge có thể chọn
          if (stats != null)
            CustomizableBadgeWidget(
              userStats: stats,
              avatarRadius: dimensions.avatarRadius,
              iconSize: dimensions.iconSize,
            )
          else
            CircleAvatar(
              radius: dimensions.avatarRadius,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: dimensions.fallbackIconSize,
                color: Theme.of(context).primaryColor,
              ),
            ),

          const SizedBox(height: 8),

          // Display Name
          Text(
            stats?.displayName ?? authViewModel.user?.name ?? 'User',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: dimensions.fontSize),
            textAlign: TextAlign.center,
          ),

          // Email
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

  Widget _buildLoadingProfile(
    BuildContext context,
    AuthViewModel authViewModel,
    _Dimensions dimensions,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: dimensions.avatarRadius * 2,
            height: dimensions.avatarRadius * 2,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(height: 8),
          Text(
            authViewModel.user?.name ?? 'Đang tải...',
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

  Widget _buildErrorProfile(
    BuildContext context,
    AuthViewModel authViewModel,
    _Dimensions dimensions,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: dimensions.avatarRadius,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Icon(
                Icons.account_circle,
                size: dimensions.avatarRadius * 1.8,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authViewModel.user?.name ?? 'User',
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
