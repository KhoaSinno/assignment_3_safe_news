# 📊 Hệ thống Tracking Đọc Bài Báo & Gamification

## 🎯 Tổng quan

Hệ thống tracking đọc bài báo với gamification real-time, tự động cập nhật thành tựu và bảng xếp hạng khi user đọc đủ 30 giây.

## 📖 Luồng hoạt động chính

```
User mở bài báo → Start timer → Đọc 30s → Trigger event → Update stats → Check achievements → Update leaderboard
```

---

## 1. 🕒 Bắt Trigger Thời Gian Đọc Bài Báo

### 1.1 Reading Timer Service

```dart
// lib/services/reading_tracker_service.dart
class ReadingTrackerService {
  Timer? _readingTimer;
  DateTime? _startTime;
  bool _hasTriggered = false;
  final int _requiredSeconds = 30;
  
  void startTracking({
    required String articleId,
    required String category,
    required VoidCallback onCompleted,
  }) {
    _startTime = DateTime.now();
    _hasTriggered = false;
    
    _readingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      
      if (elapsed >= _requiredSeconds && !_hasTriggered) {
        _hasTriggered = true;
        onCompleted();
        stopTracking();
      }
    });
  }
  
  void stopTracking() {
    _readingTimer?.cancel();
    _readingTimer = null;
  }
  
  int get elapsedSeconds {
    if (_startTime == null) return 0;
    return DateTime.now().difference(_startTime!).inSeconds;
  }
}
```

### 1.2 Integration trong Article Detail Screen

```dart
// lib/features/news/ui/article_detail_screen.dart
class ArticleDetailScreen extends ConsumerStatefulWidget {
  final Article article;
  
  @override
  _ArticleDetailScreenState createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  final ReadingTrackerService _tracker = ReadingTrackerService();
  bool _hasCompletedReading = false;
  
  @override
  void initState() {
    super.initState();
    _startTrackingReading();
  }
  
  void _startTrackingReading() {
    _tracker.startTracking(
      articleId: widget.article.id,
      category: widget.article.category,
      onCompleted: _onReadingCompleted,
    );
  }
  
  void _onReadingCompleted() async {
    if (_hasCompletedReading) return;
    
    setState(() {
      _hasCompletedReading = true;
    });
    
    // Trigger stats update
    final userStatsNotifier = ref.read(userStatsNotifierProvider);
    await userStatsNotifier.incrementArticleRead(
      category: widget.article.category,
      readingTimeSeconds: 30,
    );
    
    // Show achievement notification if any
    _showAchievementNotification();
  }
  
  @override
  void dispose() {
    _tracker.stopTracking();
    super.dispose();
  }
}
```

---

## 2. 📤 Thông Tin Gửi Đi Sau 30 Giây

### 2.1 Reading Event Data

```dart
class ReadingEventData {
  final String userId;
  final String articleId;
  final String category;
  final int readingTimeSeconds;
  final DateTime timestamp;
  
  ReadingEventData({
    required this.userId,
    required this.articleId,
    required this.category,
    required this.readingTimeSeconds,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'article_id': articleId,
    'category': category,
    'reading_time_seconds': readingTimeSeconds,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

### 2.2 Thông tin được gửi

- **userId**: ID của user hiện tại
- **articleId**: ID bài báo đã đọc
- **category**: Danh mục bài báo (Thể thao, Giải trí, v.v.)
- **readingTimeSeconds**: Thời gian đọc (30 giây)
- **timestamp**: Thời điểm hoàn thành đọc

---

## 3. 🔄 Hàm Xử Lý & Cập Nhật Firebase

### 3.1 Enhanced UserStatsNotifier

```dart
// lib/providers/user_stats_provider.dart
class UserStatsNotifier {
  Future<void> incrementArticleRead({
    required String category,
    required int readingTimeSeconds,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      UserAchievementStatsModel currentStats;
      if (snapshot.exists) {
        currentStats = UserAchievementStatsModel.fromFirestore(snapshot.data()!);
      } else {
        currentStats = _createDefaultStats(user.uid);
      }

      // 📊 Cập nhật các thông số
      final now = DateTime.now();
      final isNewDay = !_isSameDay(currentStats.lastReadDate, now);
      
      final updatedStats = UserAchievementStatsModel(
        userId: currentStats.userId,
        articlesRead: currentStats.articlesRead + 1,           // +1 bài đọc
        currentStreak: isNewDay ? currentStats.currentStreak + 1 : currentStats.currentStreak,
        lastReadDate: now,
        readCategories: _addUniqueCategory(currentStats.readCategories, category),
        unlockedAchievements: _checkNewAchievements(currentStats, category),
        updatedAt: now,
      );

      // 💾 Lưu vào Firebase
      transaction.set(docRef, updatedStats.toFirestore());
      
      // 🏆 Cập nhật leaderboard async (không block main transaction)
      _updateLeaderboardAsync(updatedStats);
    });
  }
  
  // 🏆 Kiểm tra achievement mới
  List<Achievement> _checkNewAchievements(
    UserAchievementStatsModel currentStats, 
    String newCategory
  ) {
    final achievements = List<Achievement>.from(currentStats.unlockedAchievements);
    final newArticlesRead = currentStats.articlesRead + 1;
    final newCategories = _addUniqueCategory(currentStats.readCategories, newCategory);
    
    // ✅ First Read (1 bài)
    if (newArticlesRead >= 1 && !achievements.contains(Achievement.firstRead)) {
      achievements.add(Achievement.firstRead);
    }
    
    // ✅ Week Streak (7 ngày liên tiếp)
    if (currentStats.currentStreak >= 7 && !achievements.contains(Achievement.weekStreak)) {
      achievements.add(Achievement.weekStreak);
    }
    
    // ✅ Explorer (3 danh mục khác nhau)
    if (newCategories.length >= 3 && !achievements.contains(Achievement.explorer)) {
      achievements.add(Achievement.explorer);
    }
    
    // ✅ Bookworm (50 bài)
    if (newArticlesRead >= 50 && !achievements.contains(Achievement.bookworm)) {
      achievements.add(Achievement.bookworm);
    }
    
    return achievements;
  }
}
```

---

## 4. 🏆 Hệ Thống Bảng Xếp Hạng

### 4.1 Leaderboard Model

```dart
// lib/features/leaderboard/model/leaderboard_model.dart
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String avatarAssetPath;
  final int articlesRead;
  final int currentStreak;
  final int categoriesExplored;
  final int achievementCount;
  final int totalScore; // Điểm tổng hợp
  
  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.avatarAssetPath,
    required this.articlesRead,
    required this.currentStreak,
    required this.categoriesExplored,
    required this.achievementCount,
    required this.totalScore,
  });
  
  // 🧮 Tính điểm tổng hợp
  static int calculateTotalScore({
    required int articlesRead,
    required int currentStreak,
    required int categoriesExplored,
    required int achievementCount,
  }) {
    return (articlesRead * 10) +           // 10 điểm/bài
           (currentStreak * 50) +          // 50 điểm/ngày streak
           (categoriesExplored * 100) +    // 100 điểm/danh mục
           (achievementCount * 200);       // 200 điểm/achievement
  }
}
```

### 4.2 Leaderboard Service

```dart
// lib/services/leaderboard_service.dart
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // 📊 Lấy top users cho bảng xếp hạng
  Stream<List<LeaderboardEntry>> getTopUsers({int limit = 50}) {
    return _firestore
        .collection('users')
        .orderBy('total_score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final stats = UserAchievementStatsModel.fromFirestore(data);
            
            return LeaderboardEntry(
              userId: stats.userId,
              displayName: stats.displayName,
              avatarAssetPath: stats.avatarAssetPath,
              articlesRead: stats.articlesRead,
              currentStreak: stats.currentStreak,
              categoriesExplored: stats.readCategories.length,
              achievementCount: stats.unlockedAchievements.length,
              totalScore: data['total_score'] ?? 0,
            );
          }).toList();
        });
  }
  
  // 🔄 Cập nhật điểm user trong leaderboard
  Future<void> updateUserScore(UserAchievementStatsModel stats) async {
    final totalScore = LeaderboardEntry.calculateTotalScore(
      articlesRead: stats.articlesRead,
      currentStreak: stats.currentStreak,
      categoriesExplored: stats.readCategories.length,
      achievementCount: stats.unlockedAchievements.length,
    );
    
    await _firestore
        .collection('users')
        .doc(stats.userId)
        .update({'total_score': totalScore});
  }
}
```

### 4.3 Cập nhật Model để hỗ trợ Leaderboard

```dart
// Thêm vào UserAchievementStatsModel.toFirestore()
Map<String, dynamic> toFirestore() {
  final totalScore = LeaderboardEntry.calculateTotalScore(
    articlesRead: articlesRead,
    currentStreak: currentStreak,
    categoriesExplored: readCategories.length,
    achievementCount: unlockedAchievements.length,
  );
  
  return {
    'user_id': userId,
    'articles_read': articlesRead,
    'current_streak': currentStreak,
    'last_read_date': Timestamp.fromDate(lastReadDate),
    'read_categories': readCategories,
    'unlocked_achievements': unlockedAchievements.map((a) => a.name).toList(),
    'updated_at': Timestamp.fromDate(updatedAt),
    'total_score': totalScore, // 🏆 Điểm leaderboard
  };
}
```

---

## 5. 🎮 UI Components

### 5.1 Reading Progress Indicator

```dart
// lib/widgets/reading_progress_indicator.dart
class ReadingProgressIndicator extends StatefulWidget {
  final ReadingTrackerService tracker;
  final VoidCallback? onCompleted;
  
  @override
  _ReadingProgressIndicatorState createState() => _ReadingProgressIndicatorState();
}

class _ReadingProgressIndicatorState extends State<ReadingProgressIndicator> {
  Timer? _uiTimer;
  int _seconds = 0;
  
  @override
  void initState() {
    super.initState();
    _startUITimer();
  }
  
  void _startUITimer() {
    _uiTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds = widget.tracker.elapsedSeconds;
      });
      
      if (_seconds >= 30) {
        timer.cancel();
        widget.onCompleted?.call();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final progress = (_seconds / 30.0).clamp(0.0, 1.0);
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: _seconds >= 30 ? Colors.green : Colors.blue,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _seconds >= 30 ? '✅ Hoàn thành!' : '$_seconds/30s',
            style: TextStyle(
              color: _seconds >= 30 ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 5.2 Achievement Notification

```dart
// lib/widgets/achievement_notification.dart
void showAchievementNotification(BuildContext context, Achievement achievement) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.gold,
            ),
            SizedBox(height: 16),
            Text(
              'Thành tựu mới!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              achievement.title,
              style: TextStyle(
                fontSize: 18,
                color: achievement.color,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tuyệt vời!'),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

## 6. 🤔 Thắc Mắc & Giải Đáp

### Q1: Làm sao đảm bảo user thực sự đọc bài chứ không chỉ mở rồi để đó?

**A:** Có thể thêm các điều kiện:

- Scroll detection (user phải scroll xuống)
- Focus detection (app phải ở foreground)
- Interaction tracking (tap, scroll events)

```dart
class EnhancedReadingTracker {
  bool _hasScrolled = false;
  bool _isAppInForeground = true;
  
  void onScroll() {
    _hasScrolled = true;
  }
  
  bool get isValidReading => _hasScrolled && _isAppInForeground;
}
```

### Q2: Nếu user tắt app giữa chừng thì sao?

**A:** Timer sẽ tự động reset, không засчитывается. Chỉ tính khi hoàn thành 30s liên tục trong app.

### Q3: Làm sao tránh spam (đọc cùng 1 bài nhiều lần)?

**A:** Lưu articleId đã đọc trong session hoặc database:

```dart
class ReadingHistoryService {
  final Set<String> _readArticlesInSession = {};
  
  bool hasReadArticle(String articleId) {
    return _readArticlesInSession.contains(articleId);
  }
  
  void markAsRead(String articleId) {
    _readArticlesInSession.add(articleId);
  }
}
```

### Q4: Performance khi có nhiều user?

**A:**

- Dùng Firestore Transactions để tránh race conditions
- Batch operations cho leaderboard updates
- Cache leaderboard data với TTL
- Pagination cho leaderboard

### Q5: Offline support?

**A:**

- Firebase có offline persistence mặc định
- Local storage cho tracking data
- Sync khi online trở lại

---

## 7. 🚀 Implementation Steps

### Phase 1: Basic Tracking

1. ✅ Tạo ReadingTrackerService
2. ✅ Tích hợp vào ArticleDetailScreen  
3. ✅ Update UserStatsNotifier

### Phase 2: Enhanced Features

1. ✅ Achievement system
2. ✅ Reading progress UI
3. ✅ Achievement notifications

### Phase 3: Leaderboard

1. ✅ LeaderboardService
2. ✅ Score calculation
3. ✅ Leaderboard UI

### Phase 4: Optimizations

1. 🔄 Enhanced tracking validation
2. 🔄 Performance optimizations
3. 🔄 Offline support

---

## 📊 Database Structure

```
/users/{userId}
{
  "user_id": "string",
  "articles_read": number,
  "current_streak": number,
  "last_read_date": timestamp,
  "read_categories": ["category1", "category2"],
  "unlocked_achievements": ["newbie", "firstRead"],
  "updated_at": timestamp,
  "total_score": number  // For leaderboard
}
```

---

## 🎯 Kết luận

Hệ thống tracking này cung cấp:

- ⏱️ **Real-time tracking** đọc bài báo 30 giây
- 📊 **Automatic stats update** với Firebase
- 🏆 **Achievement system** với real-time notifications  
- 📈 **Leaderboard** với scoring system
- 🎮 **Gamification** tăng engagement user

Tất cả được thiết kế đơn giản, scalable và easy to maintain cho MVP! 🚀
