import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';

class UserRankingModel {
  final String userId;
  final String displayName;
  final int articlesRead;
  final int currentStreak;
  final List<Achievement> unlockedAchievements;
  final int totalScore;
  final Achievement topAchievement;

  UserRankingModel({
    required this.userId,
    required this.displayName,
    required this.articlesRead,
    required this.currentStreak,
    required this.unlockedAchievements,
    required this.totalScore,
    required this.topAchievement,
  });

  factory UserRankingModel.fromFirestore(Map<String, dynamic> data) {
    final achievements =
        (data['unlocked_achievements'] as List<dynamic>?)
            ?.map(
              (name) => Achievement.values.firstWhere(
                (a) => a.name == name,
                orElse: () => Achievement.newbie,
              ),
            )
            .toList() ??
        [Achievement.newbie];

    final topAchievement =
        achievements.isEmpty
            ? Achievement.newbie
            : achievements.reduce((a, b) => a.priority > b.priority ? a : b);

    // Tính điểm tổng hợp dựa trên các yếu tố
    final totalScore = _calculateTotalScore(
      data['articles_read'] ?? 0,
      data['current_streak'] ?? 0,
      achievements,
    );

    return UserRankingModel(
      userId: data['user_id'] ?? '',
      displayName:
          data['display_name'] ?? data['email']?.split('@')[0] ?? 'User',
      articlesRead: data['articles_read'] ?? 0,
      currentStreak: data['current_streak'] ?? 0,
      unlockedAchievements: achievements,
      totalScore: totalScore,
      topAchievement: topAchievement,
    );
  }

  // Công thức tính điểm ranking
  static int _calculateTotalScore(
    int articlesRead,
    int currentStreak,
    List<Achievement> achievements,
  ) {
    int score = 0;

    // Điểm cho số bài đọc (mỗi bài = 10 điểm)
    score += articlesRead * 10;

    // Điểm cho streak hiện tại (mỗi ngày = 5 điểm)
    score += currentStreak * 5;

    // Điểm bonus cho achievements (theo priority)
    for (final achievement in achievements) {
      score += achievement.priority * 20;
    }

    return score;
  }
}
