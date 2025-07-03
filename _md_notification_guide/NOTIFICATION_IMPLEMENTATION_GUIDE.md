# 🚀 Safe News - Notification Implementation Guide

## 📋 Quick Start cho Developer

### **Thiết lập môi trường phát triển**

#### **1. Prerequisites**
```bash
# Flutter version requirements
flutter --version
# Flutter 3.16.0 hoặc mới hơn

# Firebase CLI
npm install -g firebase-tools
firebase --version

# Android SDK 
# Minimum SDK: 24 (Android 7.0)
# Target SDK: 34 (Android 14)
```

#### **2. Clone và Setup Project**
```bash
# Clone repository
git clone <repository-url>
cd assignment_3_safe_news

# Install dependencies
flutter pub get

# Firebase setup
firebase login
firebase use <your-project-id>

# Generate Firebase options
flutterfire configure
```

#### **3. Environment Configuration**
```dart
// lib/environment/app_config.dart
class AppConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);
  static const String fcmServerKey = String.fromEnvironment('FCM_SERVER_KEY');
  static const Duration notificationCheckInterval = Duration(hours: 2);
  
  // Debug settings
  static const bool enableNotificationLogs = !isProduction;
  static const bool enableTestNotifications = !isProduction;
}
```

---

## 🔧 Step-by-Step Implementation

### **Step 1: Firebase Setup**

#### **A. Firebase Console Configuration**
1. Tạo project mới trong [Firebase Console](https://console.firebase.google.com)
2. Enable Cloud Messaging
3. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
4. Cấu hình FCM trong project settings

#### **B. Android Configuration**
```kotlin
// android/app/build.gradle.kts
android {
    compileSdk 34
    
    defaultConfig {
        applicationId "com.safenews.assignment3"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-messaging:23.4.0")
    implementation("androidx.work:work-runtime:2.9.0")
}
```

#### **C. iOS Configuration**
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>remote-notification</string>
</array>

<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### **Step 2: Core Service Implementation**

#### **A. Initialize NotificationService**
```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notification Service
  await NotificationService().initialize();
  
  // Start periodic checking
  NewsNotificationScheduler().startPeriodicCheck();
  
  runApp(const MyApp());
}
```

#### **B. Setup Providers**
```dart
// main.dart - Provider setup
void main() async {
  // ... initialization code ...
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Safe News',
      home: const MainScreen(),
    );
  }
}
```

### **Step 3: UI Integration**

#### **A. Notification Settings Widget**
```dart
// features/profile/widget/notification_settings_widget.dart
class NotificationSettingsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main toggle
            ListTile(
              title: Text('Thông báo'),
              subtitle: Text('Nhận thông báo khi có tin mới'),
              trailing: Switch(
                value: settings.isEnabled,
                onChanged: notifier.toggleNotifications,
              ),
            ),
            
            if (settings.isEnabled) ...[
              Divider(),
              Text('Danh mục', style: Theme.of(context).textTheme.titleMedium),
              
              // Category toggles
              ...NotificationService().getNotificationCategories().map(
                (category) => CheckboxListTile(
                  title: Text(_getCategoryDisplayName(category)),
                  value: settings.categorySubscriptions[category] ?? false,
                  onChanged: (value) => notifier.toggleCategorySubscription(
                    category, 
                    value ?? false,
                  ),
                ),
              ),
              
              // Test button
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  onPressed: notifier.sendTestNotification,
                  child: Text('Gửi thông báo thử'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### **B. Integration into Profile Page**
```dart
// features/profile/profile_page.dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // User info widgets...
            
            SizedBox(height: 24),
            
            // Notification Settings
            NotificationSettingsWidget(),
            
            // Other settings...
          ],
        ),
      ),
    );
  }
}
```

---

## 🧪 Testing Strategy

### **Unit Testing**

#### **A. Service Tests**
```dart
// test/utils/notification_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}
class MockFlutterLocalNotifications extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService service;
    late MockFirebaseMessaging mockFirebaseMessaging;
    late MockFlutterLocalNotifications mockLocalNotifications;
    
    setUp(() {
      mockFirebaseMessaging = MockFirebaseMessaging();
      mockLocalNotifications = MockFlutterLocalNotifications();
      service = NotificationService.forTesting(
        firebaseMessaging: mockFirebaseMessaging,
        localNotifications: mockLocalNotifications,
      );
    });
    
    test('should initialize without errors', () async {
      when(mockFirebaseMessaging.requestPermission())
          .thenAnswer((_) async => NotificationSettings(
            authorizationStatus: AuthorizationStatus.authorized,
          ));
      
      expect(() => service.initialize(), returnsNormally);
    });
    
    test('should subscribe to category successfully', () async {
      when(mockFirebaseMessaging.subscribeToTopic(any))
          .thenAnswer((_) async {});
      
      await service.subscribeToCategoryNotifications('sports', true);
      
      verify(mockFirebaseMessaging.subscribeToTopic('news_sports')).called(1);
    });
    
    test('should send local notification', () async {
      when(mockLocalNotifications.show(any, any, any, any))
          .thenAnswer((_) async {});
      
      await service.showNotification(
        title: 'Test',
        body: 'Test notification',
      );
      
      verify(mockLocalNotifications.show(any, 'Test', 'Test notification', any))
          .called(1);
    });
  });
}
```

#### **B. Provider Tests**
```dart
// test/providers/notification_settings_provider_test.dart
void main() {
  group('NotificationSettingsProvider Tests', () {
    late ProviderContainer container;
    late MockNotificationService mockService;
    
    setUp(() {
      mockService = MockNotificationService();
      container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockService),
        ],
      );
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should load initial settings', () async {
      when(mockService.areNotificationsEnabled())
          .thenAnswer((_) async => true);
      when(mockService.isSubscribedToCategory(any))
          .thenAnswer((_) async => false);
      
      final notifier = container.read(notificationSettingsProvider.notifier);
      await notifier.loadSettings();
      
      final state = container.read(notificationSettingsProvider);
      expect(state.isEnabled, true);
    });
    
    test('should toggle notifications', () async {
      when(mockService.setNotificationsEnabled(any))
          .thenAnswer((_) async {});
      
      final notifier = container.read(notificationSettingsProvider.notifier);
      await notifier.toggleNotifications(true);
      
      verify(mockService.setNotificationsEnabled(true)).called(1);
    });
  });
}
```

### **Widget Testing**

```dart
// test/features/profile/notification_settings_widget_test.dart
void main() {
  testWidgets('NotificationSettingsWidget displays correctly', (tester) async {
    final container = ProviderContainer(
      overrides: [
        notificationSettingsProvider.overrideWith(
          (ref) => MockNotificationSettingsNotifier(),
        ),
      ],
    );
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: NotificationSettingsWidget(),
          ),
        ),
      ),
    );
    
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
    expect(find.text('Gửi thông báo thử'), findsOneWidget);
  });
  
  testWidgets('can toggle notification settings', (tester) async {
    // Test implementation...
  });
}
```

### **Integration Testing**

```dart
// integration_test/notification_flow_test.dart
void main() {
  group('Notification Integration Tests', () {
    testWidgets('complete notification flow works', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Navigate to profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Find notification settings
      expect(find.text('Thông báo'), findsOneWidget);
      
      // Toggle notifications
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      
      // Select category
      await tester.tap(find.text('Công nghệ'));
      await tester.pumpAndSettle();
      
      // Send test notification
      await tester.tap(find.text('Gửi thông báo thử'));
      await tester.pumpAndSettle();
      
      // Verify state
      // Add assertions based on your app's behavior
    });
  });
}
```

---

## 🚢 Deployment Guide

### **Pre-Deployment Checklist**

#### **Development Environment**
- [ ] All tests passing (unit, widget, integration)
- [ ] Firebase project configured correctly
- [ ] FCM keys và certificates setup
- [ ] Notification channels created and tested
- [ ] Permission flows tested on multiple devices
- [ ] Background processing tested
- [ ] Memory leaks checked và fixed

#### **Production Environment**
- [ ] Production Firebase project setup
- [ ] Production FCM server key configured
- [ ] iOS push certificates uploaded
- [ ] Android signing key configured
- [ ] Analytics tracking implemented
- [ ] Error monitoring setup (Crashlytics, Sentry)
- [ ] Performance monitoring enabled

### **Build Configuration**

#### **Android Production Build**
```bash
# Clean build
flutter clean
flutter pub get

# Build production APK
flutter build apk --release --target-platform android-arm64

# Build App Bundle for Play Store
flutter build appbundle --release
```

#### **iOS Production Build**
```bash
# Clean build
flutter clean
flutter pub get

# Build for iOS
flutter build ios --release --no-codesign

# Build for App Store
flutter build ipa
```

### **Firebase Configuration**

#### **Production FCM Setup**
```dart
// firebase_options_production.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-production-api-key',
    appId: 'your-production-app-id',
    messagingSenderId: 'your-production-sender-id',
    projectId: 'your-production-project-id',
    storageBucket: 'your-production-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-production-ios-api-key',
    appId: 'your-production-ios-app-id',
    messagingSenderId: 'your-production-sender-id',
    projectId: 'your-production-project-id',
    storageBucket: 'your-production-storage-bucket',
    iosBundleId: 'com.yourcompany.safenews',
  );
}
```

---

## 📊 Monitoring và Maintenance

### **Performance Monitoring**

#### **Firebase Performance Monitoring**
```dart
// utils/performance_monitor.dart
class NotificationPerformanceMonitor {
  static final FirebasePerformance _performance = FirebasePerformance.instance;
  
  static Future<T> trackNotificationOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace('notification_$operationName');
    await trace.start();
    
    try {
      final result = await operation();
      trace.setMetric('success', 1);
      return result;
    } catch (e) {
      trace.setMetric('error', 1);
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }
  
  static Future<void> trackNotificationDelivery({
    required String category,
    required bool isSuccessful,
    required int deliveryTimeMs,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'notification_delivery',
      parameters: {
        'category': category,
        'successful': isSuccessful ? 1 : 0,
        'delivery_time_ms': deliveryTimeMs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

// Usage example
Future<void> sendNotificationWithTracking({
  required String title,
  required String body,
  required String category,
}) async {
  final startTime = DateTime.now();
  
  await NotificationPerformanceMonitor.trackNotificationOperation(
    'send_notification',
    () async {
      await NotificationService().showNotification(
        title: title,
        body: body,
      );
      
      final deliveryTime = DateTime.now().difference(startTime).inMilliseconds;
      
      await NotificationPerformanceMonitor.trackNotificationDelivery(
        category: category,
        isSuccessful: true,
        deliveryTimeMs: deliveryTime,
      );
    },
  );
}
```

### **Error Monitoring**

#### **Crashlytics Integration**
```dart
// utils/error_handler.dart
class NotificationErrorHandler {
  static Future<void> initialize() async {
    FlutterError.onError = (errorDetails) {
      if (errorDetails.library?.contains('notification') == true) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      }
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      if (error.toString().contains('notification')) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: true,
        );
      }
      return true;
    };
  }
  
  static Future<void> reportNotificationError({
    required String operation,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Notification Error: $operation',
      information: [
        'operation: $operation',
        if (context != null) ...context.entries.map((e) => '${e.key}: ${e.value}'),
      ],
    );
  }
  
  static Future<void> setNotificationUserInfo({
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    
    if (metadata != null) {
      for (final entry in metadata.entries) {
        await FirebaseCrashlytics.instance.setCustomKey(
          'notification_${entry.key}',
          entry.value,
        );
      }
    }
  }
}
```

---

## 🔄 Future Enhancements

### **Planned Features**

#### **1. Rich Media Notifications**
- Image attachments trong notifications
- Video preview thumbnails
- Audio message notifications
- Interactive polls trong notifications

#### **2. Advanced Personalization**
- AI-powered content recommendations
- Reading behavior analysis
- Smart notification timing
- Content similarity detection

#### **3. Social Features**
- Notification sharing
- Community-driven alerts
- Social proof in notifications
- Friend activity notifications

#### **4. Enterprise Features**
- Admin dashboard for notification management
- Bulk notification scheduling
- A/B testing for notification content
- Advanced analytics và reporting

### **Technical Roadmap**

#### **Q1 2025**
- [ ] Implement rich media notifications
- [ ] Add notification history view
- [ ] Improve background processing efficiency
- [ ] Add more granular category options

#### **Q2 2025**
- [ ] Machine learning for optimal timing
- [ ] Advanced analytics dashboard
- [ ] Social sharing features
- [ ] Multi-language notification support

#### **Q3 2025**
- [ ] Enterprise admin features
- [ ] A/B testing framework
- [ ] Advanced personalization engine
- [ ] Cross-platform notification sync

---

## 📞 Support và Resources

### **Documentation Links**
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [iOS Push Notifications](https://developer.apple.com/documentation/usernotifications)

### **Contact Information**
- **Technical Lead**: [Lead Developer Email]
- **Project Manager**: [PM Email]
- **QA Lead**: [QA Email]
- **DevOps**: [DevOps Email]

### **Emergency Contacts**
- **Production Issues**: [Emergency Email]
- **Firebase Support**: [Firebase Support Email]
- **Security Issues**: [Security Email]

---

*🚀 Document này cung cấp hướng dẫn đầy đủ để implement, test, deploy và maintain hệ thống notification của Safe News app!*

**📅 Version**: 1.0  
**👥 Author**: Safe News Development Team  
**📊 Last Updated**: January 16, 2025
