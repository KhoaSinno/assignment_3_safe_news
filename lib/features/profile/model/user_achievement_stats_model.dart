import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievementStatsModel {
  final String userId;
  final int articlesRead;
  final int currentStreak;
  final DateTime lastReadDate;
  final List<String> readCategories;
  final List<Achievement> unlockedAchievements;
  final DateTime updatedAt;

  UserAchievementStatsModel({
    required this.userId,
    this.articlesRead = 0,
    this.currentStreak = 0,
    required this.lastReadDate,
    this.readCategories = const [],
    this.unlockedAchievements = const [],
    required this.updatedAt,
  });

  // Lấy achievement hiển thị (priority cao nhất)
  Achievement get sortedAchievement {
    if (unlockedAchievements.isEmpty) return Achievement.newbie;

    // Sort theo priority và lấy cao nhất
    final sorted =
        unlockedAchievements.toList()
          ..sort((a, b) => b.priority.compareTo(a.priority));
    return sorted.first;
  }

  // Profile name = Achievement title
  String get displayName => sortedAchievement.title;

  // Profile avatar = Achievement SVG path
  String get avatarAssetPath => sortedAchievement.assetPath;

  // Send to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'articles_read': articlesRead,
      'current_streak': currentStreak,
      'last_read_date': Timestamp.fromDate(lastReadDate),
      'read_categories': readCategories,
      'unlocked_achievements': unlockedAchievements.map((a) => a.name).toList(),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert from Firestore data
  factory UserAchievementStatsModel.fromFirestore(Map<String, dynamic> data) {
    return UserAchievementStatsModel(
      userId: data['user_id'] ?? '',
      articlesRead: data['articles_read'] ?? 0,
      currentStreak: data['current_streak'] ?? 0,
      lastReadDate:
          (data['last_read_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readCategories: List<String>.from(data['read_categories'] ?? []),
      unlockedAchievements:
          (data['unlocked_achievements'] as List<dynamic>?)
              ?.map(
                (name) => Achievement.values.firstWhere(
                  (a) => a.name == name,
                  orElse: () => Achievement.newbie,
                ),
              )
              .toList() ??
          [Achievement.newbie],
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // fetch user from firebase
  // static Future<UserAchievementStatsModel> fetchUserStats(String userId) async {
  //   final doc =
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userId)
  //           .get();

  //   if (doc.exists) {
  //     return UserAchievementStatsModel.fromFirestore(doc.data()!);
  //   } else {
  //     // Return default stats if not found
  //     return UserAchievementStatsModel(
  //       userId: userId,
  //       lastReadDate: DateTime.now(),
  //       unlockedAchievements: [Achievement.newbie],
  //       updatedAt: DateTime.now(),
  //     );
  //   }
  // }
}
