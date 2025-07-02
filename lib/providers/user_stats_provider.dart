import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_achievement_stats_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Provider phụ thuộc vào auth state để auto-refresh
final userStatsProvider = StreamProvider<UserAchievementStatsModel?>((ref) {
  // ✅ Watch auth provider để auto-invalidate khi user thay đổi
  final authViewModel = ref.watch(authViewModelProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null || authViewModel.user == null) {
    print('📊 No authenticated user - returning null');
    return Stream.value(null);
  }

  print('📊 Setting up stats stream for user: ${user.uid}');

  // ✅ Tạo một stream mới cho mỗi user khác nhau
  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((
    snapshot,
  ) {
    if (!snapshot.exists) {
      // ⚠️ KHÔNG tạo document ở đây - để auth_repository.dart xử lý
      // Return default stats để UI hiển thị, nhưng không save vào Firestore
      print(
        '📊 User document not found for ${user.uid} - returning default stats for UI',
      );
      return UserAchievementStatsModel(
        userId: user.uid,
        lastReadDate: DateTime.now(),
        unlockedAchievements: [Achievement.newbie],
        updatedAt: DateTime.now(),
      );
    }

    print('📊 Loading user stats from Firestore for: ${user.uid}');
    final stats = UserAchievementStatsModel.fromFirestore(snapshot.data()!);
    print(
      '📊 Stats loaded - achievements: ${stats.unlockedAchievements.map((a) => a.name).join(', ')}',
    );
    return stats;
  });
});

final userStatsNotifierProvider = Provider<UserStatsNotifier>((ref) {
  return UserStatsNotifier();
});

class UserStatsNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> incrementArticleRead({
    required String category,
    required int readingTimeSeconds,
    required User user,
  }) async {
    // SIMPLIFIED: Flat structure - direct access to /users/{userId}
    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      UserAchievementStatsModel currentStats;

      if (snapshot.exists) {
        currentStats = UserAchievementStatsModel.fromFirestore(
          snapshot.data()!,
        );
      } else {
        currentStats = UserAchievementStatsModel(
          userId: user.uid,
          lastReadDate: DateTime.now(),
          unlockedAchievements: [Achievement.newbie], // Mặc định
          updatedAt: DateTime.now(),
        );
      }

      // Update stats
      final now = Timestamp.now().toDate();

      final isNewDay = !_isSameDay(currentStats.lastReadDate, now);
      print('isNewDay: $isNewDay');

      List<String> updatedCategories = _addUniqueCategory(
        currentStats.readCategories,
        category,
      );

      final UserAchievementStatsModel updatedStats = UserAchievementStatsModel(
        userId: currentStats.userId,
        articlesRead: currentStats.articlesRead + 1,
        currentStreak:
            isNewDay
                ? currentStats.currentStreak + 1
                : currentStats.currentStreak,
        lastReadDate: now,
        readCategories: updatedCategories,
        unlockedAchievements: _checkNewAchievements(
          currentStats,
          currentStats.articlesRead + 1,
          updatedCategories,
        ),
        updatedAt: now,
      );

      // Print thông tin của updatedStats
      print('Updated Stats:');
      print('User ID: ${updatedStats.userId}');
      print('Articles Read: ${updatedStats.articlesRead}');
      print('Current Streak: ${updatedStats.currentStreak}');
      print('Last Read Date: ${updatedStats.lastReadDate}');
      print('Read Categories: ${updatedStats.readCategories}');
      print('Unlocked Achievements: ${updatedStats.unlockedAchievements}');
      print('Updated At: ${updatedStats.updatedAt}');

      transaction.set(docRef, updatedStats.toFirestore());
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<String> _addUniqueCategory(List<String> categories, String newCategory) {
    if (!categories.contains(newCategory)) {
      return [...categories, newCategory];
    }
    return categories;
  }

  List<Achievement> _checkNewAchievements(
    UserAchievementStatsModel currentStats,
    int newArticlesRead,
    List<String> newCategories,
  ) {
    final achievements = List<Achievement>.from(
      currentStats.unlockedAchievements,
    );

    // Check first read
    if (newArticlesRead >= 1 && !achievements.contains(Achievement.firstRead)) {
      achievements.add(Achievement.firstRead);
    }

    // Check daily reader (5 articles in one day)
    // This would need additional logic to track daily reads

    // Check week streak
    if (currentStats.currentStreak >= 7 &&
        !achievements.contains(Achievement.weekStreak)) {
      achievements.add(Achievement.weekStreak);
    }

    // Check explorer (3 different categories)
    if (newCategories.length >= 3 &&
        !achievements.contains(Achievement.explorer)) {
      achievements.add(Achievement.explorer);
    }

    // Check bookworm (50 articles)
    if (newArticlesRead >= 50 && !achievements.contains(Achievement.bookworm)) {
      achievements.add(Achievement.bookworm);
    }

    return achievements;
  }
}
