import 'package:assignment_3_safe_news/features/profile/model/user_ranking_model.dart';
import 'package:assignment_3_safe_news/providers/ranking_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimpleLeaderboardScreen extends ConsumerWidget {
  const SimpleLeaderboardScreen({super.key});

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
        data: (users) => _buildSimpleList(context, users),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  Text('Lỗi: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(leaderboardProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildSimpleList(BuildContext context, List<UserRankingModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có dữ liệu xếp hạng'),
            Text('Hãy đọc vài bài báo để xuất hiện!'),
          ],
        ),
      );
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final rank = index + 1;
        final isCurrentUser =
            currentUser != null && user.userId == currentUser.uid;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color:
              isCurrentUser
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRankColor(rank),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              user.displayName,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser ? Theme.of(context).primaryColor : null,
              ),
            ),
            subtitle: Text(
              '${user.articlesRead} bài đọc • ${user.unlockedAchievements.length} thành tựu',
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.blue;
    }
  }
}
