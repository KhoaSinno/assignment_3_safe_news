import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_ranking_model.dart';
import 'package:assignment_3_safe_news/providers/ranking_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng xếp hạng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(leaderboardProvider);
              ref.invalidate(currentUserRankingProvider);
            },
          ),
        ],
      ),
      body: leaderboardAsync.when(
        data: (users) => _buildLeaderboard(context, users),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, error.toString()),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<UserRankingModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu xếp hạng',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Hãy đọc vài bài báo để xuất hiện trong bảng xếp hạng!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Top 3 podium
        if (users.length >= 3)
          Builder(
            builder: (context) {
              try {
                return _buildPodium(context, users.take(3).toList());
              } catch (e) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: Text('Lỗi hiển thị top 3')),
                );
              }
            },
          ),

        // Rest of the leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length > 3 ? users.length - 3 : users.length,
            itemBuilder: (context, index) {
              try {
                final user = users.length > 3 ? users[index + 3] : users[index];
                final rank = users.length > 3 ? index + 4 : index + 1;
                return _buildLeaderboardItem(context, user, rank);
              } catch (e) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text('Lỗi hiển thị user'),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(BuildContext context, List<UserRankingModel> topThree) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length > 1)
            _buildPodiumItem(context, topThree[1], 2, 120),
          // 1st place
          _buildPodiumItem(context, topThree[0], 1, 160),
          // 3rd place
          if (topThree.length > 2)
            _buildPodiumItem(context, topThree[2], 3, 100),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    UserRankingModel user,
    int rank,
    double height,
  ) {
    final colors = _getPodiumColors(rank);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser != null && user.userId == currentUser.uid;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // User avatar with crown/medal
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors['background'],
                border: Border.all(
                  color:
                      isCurrentUser
                          ? Theme.of(context).primaryColor
                          : colors['border']!,
                  width: isCurrentUser ? 4 : 3,
                ),
              ),
              child: ClipOval(
                child: SvgPicture.asset(
                  user.topAchievement.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('DEBUG: SVG Error for ${user.displayName}: $error');
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors['background'],
                      ),
                      child: Icon(
                        user.topAchievement.icon,
                        color: colors['icon'],
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (rank == 1)
              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
          ],
        ),
        const SizedBox(height: 8),

        // User name
        SizedBox(
          width: 80,
          child: Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? Theme.of(context).primaryColor : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),

        // Score
        Text(
          '${user.totalScore}',
          style: TextStyle(
            fontSize: 10,
            color: colors['text'],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Podium base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors['gradient1']!, colors['gradient2']!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${user.articlesRead} bài',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    UserRankingModel user,
    int rank,
  ) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser != null && user.userId == currentUser.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isCurrentUser
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(rank),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: user.topAchievement.color.withOpacity(0.1),
            child: ClipOval(
              child: SvgPicture.asset(
                user.topAchievement.assetPath,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print(
                    'DEBUG: SVG Error in list for ${user.displayName}: $error',
                  );
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.topAchievement.color.withOpacity(0.2),
                    ),
                    child: Icon(
                      user.topAchievement.icon,
                      color: user.topAchievement.color,
                      size: 20,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${user.articlesRead} bài đọc • ${user.unlockedAchievements.length} thành tựu',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.totalScore}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'điểm',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Lỗi khi tải bảng xếp hạng',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getPodiumColors(int rank) {
    switch (rank) {
      case 1:
        return {
          'background': Colors.amber.shade100,
          'border': Colors.amber.shade400,
          'icon': Colors.amber.shade700,
          'text': Colors.amber.shade800,
          'gradient1': Colors.amber.shade400,
          'gradient2': Colors.orange.shade300,
        };
      case 2:
        return {
          'background': Colors.grey.shade100,
          'border': Colors.grey.shade400,
          'icon': Colors.grey.shade700,
          'text': Colors.grey.shade800,
          'gradient1': Colors.grey.shade400,
          'gradient2': Colors.grey.shade300,
        };
      case 3:
        return {
          'background': Colors.orange.shade100,
          'border': Colors.orange.shade400,
          'icon': Colors.orange.shade700,
          'text': Colors.orange.shade800,
          'gradient1': Colors.orange.shade400,
          'gradient2': Colors.deepOrange.shade300,
        };
      default:
        return {
          'background': Colors.blue.shade100,
          'border': Colors.blue.shade400,
          'icon': Colors.blue.shade700,
          'text': Colors.blue.shade800,
          'gradient1': Colors.blue.shade400,
          'gradient2': Colors.blue.shade300,
        };
    }
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber.shade700;
    if (rank <= 10) return Colors.blue.shade600;
    if (rank <= 20) return Colors.green.shade600;
    return Colors.grey.shade600;
  }
}
