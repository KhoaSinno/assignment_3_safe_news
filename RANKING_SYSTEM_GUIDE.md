# Hệ thống Ranking User - Hướng dẫn chi tiết

## Tổng quan

Hệ thống ranking cho phép:

- Thống kê và xếp hạng người dùng dựa trên hoạt động đọc báo
- Hiển thị hạng của user hiện tại trong profile
- Xem bảng xếp hạng top users
- Tự động refresh ranking khi có thay đổi

## Cấu trúc hệ thống

### 1. Models

- `UserRankingModel`: Thông tin user cho ranking
- `UserRankingInfo`: Thông tin hạng của user hiện tại

### 2. Services

- `RankingService`: Xử lý logic ranking
  - `getAllUsersRanking()`: Lấy tất cả user và sắp xếp theo điểm
  - `getCurrentUserRanking()`: Tìm hạng của user hiện tại
  - `getTopUsers()`: Lấy top users cho leaderboard

### 3. Providers

- `currentUserRankingProvider`: Hạng của user hiện tại
- `leaderboardProvider`: Top users
- `rankingRefreshProvider`: Refresh ranking manual

### 4. Widgets

- `UserRankingWidget`: Hiển thị hạng trong profile
- `LeaderboardScreen`: Bảng xếp hạng đầy đủ

## Cách tính điểm (Scoring Algorithm)

```dart
static int _calculateTotalScore(
  int articlesRead,
  int currentStreak,
  List<Achievement> achievements,
) {
  // Base score từ bài đọc
  int baseScore = articlesRead * 100;
  
  // Bonus cho streak
  int streakBonus = currentStreak * 50;
  
  // Bonus cho achievements
  int achievementBonus = achievements.fold(0, (sum, achievement) => sum + achievement.points);
  
  return baseScore + streakBonus + achievementBonus;
}
```

## Hiển thị trong Profile

```dart
// Trong profile_setting.dart
if (isLoggedIn) ...[
  // Achievement Badge
  AchievementBadge(userAchievementModel: userAchievementModel),
  const SizedBox(height: 16),
  
  // User Ranking - CHÍNH LÀ PHẦN BẠN CẦN
  const UserRankingWidget(),
  const SizedBox(height: 16),
  
  // Achievement Stats
  AchievementStat(userAchievementModel: userAchievementModel),
]
```

## Tính năng chính

### 1. UserRankingWidget

- Hiển thị hạng hiện tại: `#5 trong 50 người dùng`
- Hiển thị điểm số: `Điểm số: 1250`
- Hiển thị percentile: `Thuộc top 10%`
- Tap để xem bảng xếp hạng đầy đủ

### 2. LeaderboardScreen

- Top 3 users với podium design
- Danh sách users từ #4 trở xuống
- Hiển thị hạng, tên, điểm số, thành tựu
- Nút refresh để cập nhật dữ liệu

### 3. Auto-refresh

- Khi user đọc bài viết mới → tự động refresh ranking
- Khi có achievement mới → refresh ranking
- User có thể manual refresh trong leaderboard

## Cách sử dụng

### 1. Xem hạng cá nhân

1. Đăng nhập vào app
2. Vào Profile → Xem widget ranking
3. Tap vào widget để xem bảng xếp hạng

### 2. Cải thiện hạng

1. Đọc nhiều bài viết hơn (+100 điểm/bài)
2. Duy trì streak đọc hằng ngày (+50 điểm/ngày)
3. Mở khóa achievements (điểm thưởng khác nhau)

### 3. Xem bảng xếp hạng

1. Tap vào UserRankingWidget
2. Xem top users
3. Tap refresh để cập nhật

## Implementation Details

### Cách tìm hạng của user

```dart
// Trong RankingService
Future<UserRankingInfo> getCurrentUserRanking() async {
  final allUsers = await getAllUsersRanking(); // Đã sắp xếp theo điểm
  
  // Tìm vị trí của user hiện tại
  final userIndex = allUsers.indexWhere((user) => user.userId == currentUser.uid);
  
  if (userIndex == -1) {
    // User chưa có trong ranking
    return UserRankingInfo(rank: 0, isUnranked: true);
  }
  
  // Index + 1 = rank (vì index bắt đầu từ 0, rank từ 1)
  return UserRankingInfo(
    rank: userIndex + 1, 
    totalUsers: allUsers.length,
    userStats: allUsers[userIndex],
  );
}
```

### Cách hiển thị hạng

```dart
// Trong UserRankingWidget
Widget _buildRankingCard(BuildContext context, UserRankingInfo rankingInfo) {
  return Container(
    child: Column(
      children: [
        // Hiển thị hạng
        Text(rankingInfo.rankDisplay), // "#5" hoặc "Chưa xếp hạng"
        
        // Hiển thị mô tả
        Text(rankingInfo.rankDescription), // "#5 trong 50 người dùng"
        
        // Hiển thị điểm số
        Text('Điểm số: ${rankingInfo.userStats?.totalScore}'),
        
        // Progress bar percentile
        LinearProgressIndicator(
          value: rankingInfo.percentilePosition / 100,
        ),
      ],
    ),
  );
}
```

## Tương tác với hệ thống khác

### 1. Với User Stats

- Khi user đọc bài → `incrementArticleRead()` → auto refresh ranking
- Khi unlock achievement → auto refresh ranking

### 2. Với Authentication

- Chỉ hiển thị ranking khi đã đăng nhập
- Auto-refresh khi user thay đổi

### 3. Với Firestore

- Lấy dữ liệu từ collection `users`
- Chỉ tính ranking cho users có `articles_read > 0`

## Tối ưu hóa Performance

### 1. Caching

- Sử dụng FutureProvider để cache ranking data
- Chỉ refresh khi cần thiết

### 2. Pagination (Future)

- Hiện tại load all users, có thể thêm pagination sau
- Chỉ load top 10 cho leaderboard

### 3. Real-time Updates

- Có thể thêm Stream để real-time updates
- Hiện tại dùng manual refresh

## Kết luận

Hệ thống ranking đã hoàn thiện với:
✅ Tính toán hạng chính xác dựa trên điểm số
✅ Hiển thị hạng trong profile
✅ Bảng xếp hạng đầy đủ
✅ Auto-refresh khi có thay đổi
✅ UI đẹp với gradient và animations
✅ Error handling và loading states

**Cách sử dụng chính:** Vào Profile → Xem widget ranking → Tap để xem bảng xếp hạng đầy đủ
