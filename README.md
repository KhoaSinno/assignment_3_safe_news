# Safe News - Ứng dụng tin tức an toàn với AI

## 📱 Tổng quan dự án

**Safe News** là một ứng dụng tin tức thông minh được phát triển bằng Flutter, tích hợp Firebase và AI để cung cấp trải nghiệm đọc báo an toàn, cá nhân hóa với hệ thống thành tích gamification.

### 🎯 Tính năng chính

- **🔐 Xác thực đa dạng**: Đăng nhập email/password + Google Sign-In  
- **📰 Tin tức thông minh**: RSS crawling với AI summary và phân loại sentiment
- **🔊 Text-to-Speech**: Đọc tin tức bằng giọng nói với điều khiển thông minh
- **🏆 Hệ thống thành tích**: Gamification với badges và tracking thống kê
- **📱 Thông báo thông minh**: Push notification tùy chỉnh theo danh mục
- **💾 Cache tối ưu**: In-memory caching với giới hạn và expiry
- **🎨 Giao diện hiện đại**: Material Design 3 với dark/light theme
- **🔖 Bookmark**: Lưu tin yêu thích với sync Firebase

---

## 🏗️ Kiến trúc ứng dụng

### **State Management: Riverpod**

Ứng dụng sử dụng **Flutter Riverpod** làm giải pháp quản lý state chính với các loại Provider:

#### **1. Provider** - Cung cấp đối tượng singleton

```dart
final apiServiceProvider = Provider((ref) => ApiService());
final notificationServiceProvider = Provider((ref) => NotificationService());
```

- **Chức năng**: Cung cấp service/repository không thay đổi
- **Ví dụ**: ApiService, NotificationService, TTS Service

#### **2. StateProvider** - Quản lý state đơn giản  

```dart
final themeProvider = StateProvider<bool>((ref) => false); // Dark mode toggle
final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
```

- **Chức năng**: Quản lý boolean, string, số đơn giản
- **Ví dụ**: Theme mode, category filter, settings

#### **3. StreamProvider** - Xử lý dữ liệu real-time

```dart
final userStatsProvider = StreamProvider<UserAchievementStatsModel?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .snapshots()
      .map((snapshot) => UserAchievementStatsModel.fromFirestore(snapshot.data()!));
});
```

- **Chức năng**: Sync real-time với Firebase
- **Ví dụ**: User stats, articles stream, authentication state

#### **4. FutureProvider** - Xử lý async operations

```dart
final articlesProvider = FutureProvider.family<List<ArticleModel>, String>((ref, category) async {
  return await ArticleRepository().fetchArticles(category);
});
```

- **Chức năng**: Fetch data một lần, cache kết quả
- **Ví dụ**: Articles by category, user profile

#### **5. StateNotifierProvider** - Complex state management

```dart
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});
```

- **Chức năng**: Quản lý state phức tạp với business logic
- **Ví dụ**: Notification settings, authentication flow

---

## 🔧 Tính năng kỹ thuật chi tiết

### **1. 🔐 Authentication System**

**Xác thực đa nền tảng với fix isolation bug:**

```dart
// Auth Repository - Xử lý Google Sign-In với account switching
Future<void> signOut() async {
  try {
    await _googleSignIn.signOut(); // Clear Google account cache
    await _auth.signOut(); // Firebase sign out  
  } catch (e) {
    rethrow;
  }
}

// Fix: Tạo user document chỉ khi chưa tồn tại
Future<void> _createDefaultUserDocument(String userId) async {
  final userDoc = _firestore.collection('users').doc(userId);
  final docSnapshot = await userDoc.get();
  
  if (!docSnapshot.exists) { // ✅ Chỉ tạo khi chưa có
    await userDoc.set(defaultStats.toFirestore());
  }
}
```

**Giải quyết vấn đề:**

- ✅ Google account switching hoạt động chính xác
- ✅ User stats không bị reset khi đăng nhập lại  
- ✅ Achievements được giữ nguyên theo từng account

### **2. 🏆 Achievement System**

**Hệ thống thành tích gamification với tracking thông minh:**

```dart
// User Stats Provider - Auto-refresh với dependency injection
final userStatsProvider = StreamProvider<UserAchievementStatsModel?>((ref) {
  final authViewModel = ref.watch(authViewModelProvider); // ✅ Dependency
  final user = FirebaseAuth.instance.currentUser;
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .snapshots()
      .map((snapshot) => {
        if (snapshot.exists) {
          return UserAchievementStatsModel.fromFirestore(snapshot.data()!);
        }
        return defaultStats; // ✅ Default cho UI, không save Firestore
      });
});
```

**Các thành tích có sẵn:**

- 🏅 **Newbie**: Thành tích đầu tiên khi tạo tài khoản
- 📖 **First Read**: Đọc tin đầu tiên  
- 📚 **Bookworm**: Đọc 10+ bài viết
- 🌟 **Daily Reader**: Đọc tin hàng ngày
- 🔥 **Week Streak**: Streak 7 ngày liên tiếp
- 🧭 **Explorer**: Đọc tin từ 5+ danh mục khác nhau

### **3. 📱 Smart Notification System**

**Hệ thống thông báo thông minh với tùy chỉnh theo danh mục:**

#### **NotificationService** - Core notification handling

```dart
class NotificationService {
  // FCM + Local notifications
  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeLocalNotifications(); 
    await _initializeFirebaseMessaging();
  }
  
  // Category subscription
  Future<void> subscribeToCategoryNotifications(String category, bool subscribe) async {
    final topic = 'news_$category';
    if (subscribe) {
      await _firebaseMessaging.subscribeToTopic(topic);
    } else {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    }
  }
}
```

#### **NewsNotificationScheduler** - Automatic news monitoring

```dart
class NewsNotificationScheduler {
  // Định kỳ kiểm tra tin mới (mỗi 2 giờ)
  void startPeriodicCheck({Duration interval = const Duration(hours: 2)}) {
    _timer = Timer.periodic(interval, (_) => _checkForNewNews());
  }
  
  // Logic kiểm tra tin mới thông minh
  Future<void> _checkForNewNews() async {
    final subscribedCategories = await _getSubscribedCategories();
    final lastCheck = await _getLastCheckTime();
    
    for (final category in subscribedCategories) {
      final newArticles = await _getNewArticlesForCategory(category, lastCheck);
      for (final article in newArticles.take(3)) {
        await _sendNewsNotification(article, category);
      }
    }
  }
}
```

**Tính năng thông báo:**

- 📢 **Push Notifications**: Firebase Cloud Messaging  
- 📱 **Local Notifications**: Native notifications khi app foreground
- 🎯 **Category Subscription**: Subscribe theo danh mục tin tức
- ⏰ **Smart Timing**: Kiểm tra tin mới mỗi 2 giờ, tránh spam
- 🚫 **Duplicate Prevention**: Không gửi lại thông báo đã gửi
- 🧪 **Test Notification**: Chức năng test thông báo

### **4. 🔊 Text-to-Speech Integration**

**Singleton TTS Service với smart controls:**

```dart
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  
  // Smart speak with interruption handling
  Future<bool> speak(String text) async {
    if (_isCurrentlySpeaking) {
      await stop(); // Stop previous speech
    }
    
    await _flutterTts.speak(text);
    _isCurrentlySpeaking = true;
    return true;
  }
  
  // Global stop for any widget
  Future<void> stop() async {
    await _flutterTts.stop();
    _isCurrentlySpeaking = false;
    _currentSpeakingText = null;
  }
}
```

**Tính năng TTS:**

- 🔊 **Smart Controls**: Auto-stop khi chuyển bài
- 🎛️ **Global State**: Một instance cho toàn app
- ⚡ **Performance**: Singleton pattern, không tái tạo
- 🎯 **UI Integration**: Loading states và speaker icons

### **5. 💾 Intelligent Caching System**

**In-memory cache với size limits và expiry:**

```dart
class ArticleItemRepository {
  // Cache configuration
  static const Duration _cacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50; // Max 50 items per cache
  static const int _maxContentLength = 50000; // Max content size
  
  // Smart cache with LRU eviction
  static void _evictOldestCacheEntry() {
    if (_summaryCache.length >= _maxCacheSize) {
      final oldestKey = _cacheTimestamp.entries
          .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
          .key;
      
      _summaryCache.remove(oldestKey);
      _contentCache.remove(oldestKey);
      _cacheTimestamp.remove(oldestKey);
    }
  }
  
  // Periodic cleanup (every 6 hours)
  static void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = _cacheTimestamp.entries
        .where((entry) => now.difference(entry.value) > _cacheExpiry)
        .map((entry) => entry.key)
        .toList();
        
    for (final key in expiredKeys) {
      _summaryCache.remove(key);
      _contentCache.remove(key); 
      _cacheTimestamp.remove(key);
    }
  }
}
```

**Cache Strategy:**

- ⚡ **In-Memory**: Nhanh nhất, không cần I/O
- 📏 **Size Limits**: Max 50 items, max 50KB per content
- ⏰ **Auto Expiry**: 24 giờ, cleanup mỗi 6 giờ
- 🔄 **LRU Eviction**: Xóa item cũ nhất khi đầy
- 🧹 **Memory Management**: Cleanup định kỳ tránh memory leak

---

## 🎨 UI/UX Design

### **Modern Material Design 3**

- **Color Scheme**: Primary blue (#2196F3) với variants  
- **Typography**: Google Fonts với hierarchy rõ ràng
- **Components**: Cards, FAB, Chips, Switches hiện đại
- **Responsive**: Adaptive layout cho các màn hình khác nhau

### **Dark/Light Theme Support**

```dart
final themeProvider = StateProvider<bool>((ref) => false);

// Automatic system bar styling
systemOverlayStyle: SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,  
  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
),
```

### **Achievement Badges UI**

- 🏅 **SVG Icons**: Vector graphics với fallback handling
- 🎨 **Dynamic Colors**: Unlocked vs locked states  
- ✨ **Animations**: Smooth state transitions
- 📊 **Progress Indicators**: Visual progress tracking

---

## 🔧 Technical Stack & Dependencies

### **Core Framework**

```yaml
dependencies:
  flutter: ^3.19.0
  flutter_riverpod: ^2.6.1       # State management
  go_router: ^15.1.3             # Navigation
```

### **Firebase Integration**  

```yaml
  firebase_core: ^3.13.1         # Firebase core
  firebase_auth: ^5.5.4          # Authentication  
  cloud_firestore: ^5.6.9       # Database
  firebase_messaging: ^15.1.3    # Push notifications
  google_sign_in: ^6.3.0         # Google auth
```

### **UI & Media**

```yaml
  google_fonts: ^6.2.1           # Typography
  flutter_svg: ^2.2.0            # SVG icons
  cached_network_image: ^3.4.1   # Image caching
  flutter_widget_from_html_core: ^0.16.0  # HTML rendering
```

### **Functionality**

```yaml
  flutter_tts: ^4.2.3            # Text-to-speech
  flutter_local_notifications: ^18.0.1  # Local notifications
  permission_handler: ^12.0.0+1  # Permissions
  shared_preferences: ^2.5.3     # Local storage
  hive_flutter: ^1.1.0           # Local database
```

### **Utilities**

```yaml
  http: ^1.4.0                   # HTTP requests
  html: ^0.15.6                  # HTML parsing  
  intl: ^0.20.2                  # Internationalization
  crypto: ^3.0.6                 # Encryption utilities
```

---

## 📋 Installation & Setup

### **Prerequisites**

- Flutter SDK ≥ 3.19.0
- Dart SDK ≥ 3.3.0  
- Android Studio / VS Code
- Firebase project setup

### **Installation Steps**

1. **Clone repository**

```bash
git clone <repository-url>
cd assignment_3_safe_news
```

2. **Install dependencies**  

```bash
flutter pub get
```

3. **Configure Firebase**
   - Add `google-services.json` to `android/app/`
   - Add `firebase_options.dart` (Firebase CLI generated)

4. **Environment setup**

```bash
# Create .env file
API_KEY=your_gemini_api_key
```

5. **Run application**

```bash
flutter run
```

---

## 🚀 Key Features Walkthrough

### **1. Authentication Flow**

```
📱 Launch App
    ↓
🔐 Login Screen (Email/Password + Google)  
    ↓
✅ Authentication Success
    ↓  
🏠 Main Screen with Navigation
```

### **2. News Reading Journey**

```
📰 Browse Articles (Category filtered)
    ↓
👆 Tap Article → Detail View
    ↓  
🔊 TTS Controls (Play/Pause/Stop)
    ↓
📖 Achievement Tracking (Auto-update)
    ↓
🔖 Bookmark (Optional)
```

### **3. Notification Flow**

```
⚙️ Profile Settings → Notification Settings
    ↓
🔔 Enable/Disable Categories  
    ↓
⏰ Background Check (Every 2 hours)
    ↓
📱 Push Notification → Article Detail
```

### **4. Achievement System**

```
👤 User Action (Read article, streak, etc.)
    ↓  
📊 Stats Update (Real-time Firebase)
    ↓
🏆 Achievement Check & Unlock
    ↓
✨ UI Badge Update (Riverpod state)
```

---

## 🐛 Major Bug Fixes Implemented

### **1. Google Login Account Switching**

**Vấn đề**: Sau khi sign out, không thể chọn Google account khác  
**Giải pháp**:

```dart
await _googleSignIn.signOut(); // Clear Google cache trước
await _auth.signOut(); // Rồi mới Firebase sign out
```

### **2. Achievement Reset Bug**  

**Vấn đề**: Achievement bị reset khi login lại
**Giải pháp**:

- ✅ Chỉ tạo user document khi chưa tồn tại  
- ✅ Provider dependency để auto-refresh đúng user
- ✅ Không overwrite existing data

### **3. Circular Dependency**

**Vấn đề**: userStatsProvider ↔ authViewModelProvider circular ref
**Giải pháp**:

- ✅ userStatsProvider watch authViewModelProvider (one-way)  
- ✅ Remove manual provider invalidation
- ✅ Dependency injection pattern

### **4. Memory Management**

**Vấn đề**: Cache không có giới hạn, memory leak
**Giải pháp**:

- ✅ Size limits (50 items, 50KB content)
- ✅ LRU eviction strategy
- ✅ Periodic cleanup (6 hours)
- ✅ Automatic expiry (24 hours)

---

## 📊 Performance Optimizations

### **1. Caching Strategy**

- **Summary Cache**: Gemini AI responses (expensive API calls)
- **Content Cache**: Parsed HTML content  
- **Image Cache**: Network images với Cached Network Image
- **Memory Monitoring**: Size limits và cleanup tự động

### **2. State Management**

- **Provider Scope**: Minimal rebuild với consumer widgets
- **Auto Dispose**: Tự động hủy provider không dùng
- **Stream Optimization**: Real-time data với efficient queries

### **3. Background Processing**  

- **FCM Background**: Firebase messaging handler
- **News Monitoring**: Periodic check không block UI
- **TTS Singleton**: Một instance cho toàn app

---

## 🧪 Testing & Quality Assurance

### **Test Scenarios Covered**

1. **Authentication Testing**
   - ✅ Email/password login  
   - ✅ Google Sign-In with account switching
   - ✅ Sign out và re-login
   - ✅ User document creation logic

2. **Achievement Testing**  
   - ✅ Multi-account achievement isolation
   - ✅ Stats không bị reset
   - ✅ Real-time achievement unlock
   - ✅ Badge display accuracy

3. **Notification Testing**
   - ✅ Category subscription/unsubscription
   - ✅ Background news monitoring  
   - ✅ Duplicate notification prevention
   - ✅ Test notification functionality

4. **Performance Testing**
   - ✅ Cache hit/miss rates
   - ✅ Memory usage monitoring
   - ✅ TTS performance
   - ✅ UI responsiveness

---

## 📱 Supported Platforms

- **✅ Android**: Min SDK 24 (Android 7.0)
- **✅ iOS**: iOS 12.0+  
- **⚠️ Web**: Limited (no TTS, limited notifications)
- **❌ Desktop**: Not optimized

---

## 🚀 Deployment & Production

### **Production Checklist**

- ✅ All debug prints removed
- ✅ Production Firebase config
- ✅ Release signing configuration  
- ✅ App icons và splash screen
- ✅ Performance profiling
- ✅ Memory leak testing

### **Release Commands**

```bash
# Build release APK
flutter build apk --release

# Build release AAB (Google Play)  
flutter build appbundle --release

# iOS release build
flutter build ios --release
```

---

## 🤝 Contributing & Development

### **Code Style**

- **Linting**: `flutter analyze` zero warnings
- **Formatting**: `dart format .`
- **Architecture**: Repository pattern + Riverpod
- **Naming**: camelCase cho variables, PascalCase cho classes

### **Development Workflow**

1. Create feature branch
2. Implement với unit tests  
3. Run `flutter analyze` và `dart format`
4. Test trên real devices
5. Create pull request với documentation

---

## 📚 Documentation Files

Dự án bao gồm documentation chi tiết:

- **`TTS_OPTIMIZATION_STRATEGY.md`** - Chiến lược tối ưu TTS
- **`GOOGLE_LOGIN_ACHIEVEMENT_FIX.md`** - Fix Google login bugs
- **`ACHIEVEMENT_RESET_FIX.md`** - Fix achievement reset  
- **`ACHIEVEMENT_CACHE_FIX.md`** - Cache optimization
- **`CIRCULAR_DEPENDENCY_FIX.md`** - Dependency management
- **`DEBUG_LOGS_CLEANUP.md`** - Production cleanup guide

---

## 🎯 Future Enhancements

### **Planned Features**

- 🌐 **Offline Reading**: Cache articles for offline
- 🔍 **Advanced Search**: Full-text search với filters
- 👥 **Social Features**: Share articles, comments
- 📈 **Analytics Dashboard**: Reading habits, time spent
- 🎨 **UI Customization**: Font size, reading mode
- 🤖 **AI Recommendations**: Personalized article suggestions

### **Technical Improvements**  

- 🔄 **Background Sync**: Intelligent data sync
- ⚡ **Performance**: Widget-level optimizations
- 🧪 **Testing**: Unit và integration test coverage
- 🔒 **Security**: Enhanced encryption, secure storage
- 📊 **Monitoring**: Crash reporting, analytics

---

## 📞 Support & Contact

**Developer**: Flutter Development Team  
**Email**: <support@safenews.app>  
**Documentation**: [GitHub Wiki](github-repo-link)  
**Issues**: [GitHub Issues](github-issues-link)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Firebase Team**: Excellent cloud services
- **Flutter Team**: Amazing cross-platform framework  
- **Riverpod**: Robust state management solution
- **Material Design**: Beautiful design system
- **OpenAI**: AI integration inspiration

---

*Last updated: July 2025*  
*Version: 1.0.0*  
*Build: Production Ready* 🚀

- **Chức năng**: Thay thế `ChangeNotifierProvider` cho state đơn giản, dễ dùng, ít code.

---

### 4. **FutureProvider**

- **Mục đích**: Cung cấp dữ liệu async (như API call), chỉ fetch một lần.
- **Ví dụ**:

  ```dart
  final userProvider = FutureProvider<User>((ref) async {
    final response = await http.get(Uri.parse('https://api.example.com/user'));
    return User.fromJson(jsonDecode(response.body));
  });

  class User {
    final String name;
    User({required this.name});
    factory User.fromJson(Map<String, dynamic> json) => User(name: json['name']);
  }
  ```

- **Cách dùng**:

  ```dart
  class UserWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final user = ref.watch(userProvider);
      return user.when(
        data: (user) => Text('Name: ${user.name}'),
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }
  }
  ```

- **Chức năng**: Quản lý dữ liệu async, cache kết quả, phù hợp cho dữ liệu tĩnh.

---

### 5. **StreamProvider**

- **Mục đích**: Cung cấp stream dữ liệu, cập nhật realtime (như Firestore).
- **Ví dụ**:

  ```dart
  final articlesProvider = StreamProvider<List<String>>((ref) {
    return FirebaseFirestore.instance
        .collection('positive_news')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc['title'] as String).toList());
  });
  ```

- **Cách dùng**:

  ```dart
  class ArticlesWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final articles = ref.watch(articlesProvider);
      return articles.when(
        data: (articles) => ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) => ListTile(title: Text(articles[index])),
        ),
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }
  }
  ```

- **Chức năng**: Cập nhật UI khi dữ liệu thay đổi, phù hợp cho Firestore hoặc WebSocket.

---

### 6. **Chức năng liên quan khác**

- **ref.watch**: Lắng nghe provider, rebuild UI khi giá trị thay đổi.

  ```dart
  final value = ref.watch(myProvider); // UI rebuild khi myProvider đổi
  ```

- **ref.read**: Đọc giá trị provider một lần, không lắng nghe.

  ```dart
  ref.read(myProvider).doSomething(); // Gọi hàm, không rebuild
  ```

- **ConsumerWidget**: Widget dùng để watch/read provider.

  ```dart
  class MyWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {...}
  }
  ```

- **ProviderScope**: Bao bọc app để sử dụng Riverpod.

  ```dart
  void main() {
    runApp(ProviderScope(child: MyApp()));
  }
  ```

- **autoDispose**: Tự động hủy provider khi không còn dùng, tiết kiệm tài nguyên.

  ```dart
  final tempProvider = Provider.autoDispose((ref) => 'Temporary');
  ```

- **family**: Tạo provider với tham số động.

  ```dart
  final userProvider = FutureProvider.family<User, String>((ref, userId) async {
    return fetchUser(userId);
  });
  // Dùng: ref.watch(userProvider('123'));
  ```

## Problem

Khi lưu thêm ảnh trong rss có link ảnh vào trong firebase sẽ làm việc với thuộc tính này. Vấn đề là làm sao lấy được thẻ này từ RSS (Cách lấy từ HTML sẽ khác với cách lấy thông thường): <enclosure type="image/jpeg" length="1200" url="<https://i1-vnexpress.vnecdn.net/2025/06/13/55631871781372687471c-iran-174-3608-9354-1749777600.jpg?w=1200&h=0&q=100&dpr=1>
