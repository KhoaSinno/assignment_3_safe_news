import 'package:assignment_3_safe_news/features/profile/model/user_ranking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả users và sắp xếp theo điểm số
  Future<List<UserRankingModel>> getAllUsersRanking() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final users =
          snapshot.docs
              .map((doc) {
                try {
                  return UserRankingModel.fromFirestore(doc.data());
                } catch (e) {
                  return null;
                }
              })
              .where(
                (user) => user != null && user.articlesRead > 0,
              ) // Chỉ lấy users đã có hoạt động
              .cast<UserRankingModel>()
              .toList();

      // Sắp xếp theo điểm số từ cao đến thấp
      users.sort((a, b) => b.totalScore.compareTo(a.totalScore));

      return users;
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu ranking: $e');
    }
  }

  // Tìm hạng của user hiện tại
  Future<UserRankingInfo> getCurrentUserRanking() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User chưa đăng nhập');
    }

    try {
      final allUsers = await getAllUsersRanking();

      // Tìm vị trí của user hiện tại
      final userIndex = allUsers.indexWhere(
        (user) => user.userId == currentUser.uid,
      );

      if (userIndex == -1) {
        // User chưa có trong ranking (chưa đọc bài nào)
        return UserRankingInfo(
          rank: 0,
          totalUsers: allUsers.length,
          userStats: null,
          isUnranked: true,
        );
      }

      return UserRankingInfo(
        rank: userIndex + 1, // Index bắt đầu từ 0, rank bắt đầu từ 1
        totalUsers: allUsers.length,
        userStats: allUsers[userIndex],
        isUnranked: false,
      );
    } catch (e) {
      throw Exception('Lỗi khi tính ranking: $e');
    }
  }

  // Lấy top users (cho leaderboard)
  Future<List<UserRankingModel>> getTopUsers({int limit = 50}) async {
    final allUsers = await getAllUsersRanking();
    return allUsers.take(limit).toList();
  }
}

class UserRankingInfo {
  final int rank; // Hạng của user (1, 2, 3...)
  final int totalUsers; // Tổng số users trong ranking
  final UserRankingModel? userStats; // Stats của user
  final bool isUnranked; // User chưa có trong ranking

  UserRankingInfo({
    required this.rank,
    required this.totalUsers,
    required this.userStats,
    required this.isUnranked,
  });

  // Helper methods
  String get rankDisplay {
    if (isUnranked) return 'Chưa xếp hạng';
    return '#$rank';
  }

  String get rankDescription {
    if (isUnranked) return 'Đọc bài viết để có hạng';
    return '#$rank trong $totalUsers người dùng';
  }

  // Percentage position (for UI indicators)
  double get percentilePosition {
    if (isUnranked || totalUsers == 0) return 0.0;
    return ((totalUsers - rank + 1) / totalUsers) * 100;
  }
}
