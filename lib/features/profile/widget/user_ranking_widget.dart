import 'package:assignment_3_safe_news/features/profile/widget/simple_leaderboard_screen.dart';
import 'package:assignment_3_safe_news/providers/ranking_provider.dart';
import 'package:assignment_3_safe_news/services/ranking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRankingWidget extends ConsumerWidget {
  const UserRankingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(currentUserRankingProvider);

    return rankingAsync.when(
      data: (rankingInfo) => _buildRankingCard(context, rankingInfo),
      loading: () => _buildLoadingCard(context),
      error: (error, stack) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildRankingCard(BuildContext context, UserRankingInfo rankingInfo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SimpleLeaderboardScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                rankingInfo.isUnranked
                    ? [Colors.grey.shade300, Colors.grey.shade200]
                    : _getRankGradient(rankingInfo.rank),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRankIcon(rankingInfo.rank),
                        size: 16,
                        color: _getRankColor(rankingInfo.rank),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rankingInfo.rankDisplay,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _getRankColor(rankingInfo.rank),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              rankingInfo.rankDescription,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bấm vào để xem bảng xếp hạng',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            if (!rankingInfo.isUnranked && rankingInfo.userStats != null) ...[
              Text(
                'Điểm số: ${rankingInfo.userStats!.totalScore}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Đang tính toán hạng...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Không thể tải hạng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
                Text(
                  'Vui lòng thử lại sau',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getRankGradient(int rank) {
    if (rank <= 3) {
      // Top 3 - Gold gradient
      return [Colors.amber.shade400, Colors.orange.shade300];
    } else if (rank <= 10) {
      // Top 10 - Silver gradient
      return [Colors.blue.shade400, Colors.cyan.shade300];
    } else if (rank <= 50) {
      // Top 50 - Bronze gradient
      return [Colors.green.shade400, Colors.teal.shade300];
    } else {
      // Others - Purple gradient
      return [Colors.purple.shade400, Colors.indigo.shade300];
    }
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.amber.shade700;
    if (rank <= 10) return Colors.blue.shade700;
    if (rank <= 50) return Colors.green.shade700;
    return Colors.purple.shade700;
  }

  IconData _getRankIcon(int rank) {
    if (rank == 1) return Icons.emoji_events; // Trophy
    if (rank <= 3) return Icons.military_tech; // Medal
    if (rank <= 10) return Icons.star; // Star
    return Icons.trending_up; // Trending up
  }
}
