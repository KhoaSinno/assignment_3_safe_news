# 🔧 Safe News - Troubleshooting & Maintenance Guide

## 🚨 Common Issues & Quick Fixes

### **Issue 1: Notifications không hiển thị**

#### **Symptoms:**
- User report không nhận được notifications
- Test notifications không hoạt động
- App có permissions nhưng vẫn không notification

#### **Diagnosis Steps:**
```dart
// Run diagnostic trong debug mode
Future<void> debugNotificationIssue() async {
  print('=== NOTIFICATION DIAGNOSTIC ===');
  
  // 1. Check permissions
  final hasPermission = await Permission.notification.isGranted;
  print('Has notification permission: $hasPermission');
  
  // 2. Check FCM token
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: ${token?.substring(0, 20)}...');
  } catch (e) {
    print('FCM Token error: $e');
  }
  
  // 3. Check channels
  final plugin = FlutterLocalNotificationsPlugin();
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidPlugin != null) {
    final channels = await androidPlugin.getNotificationChannels();
    print('Available channels: ${channels?.map((c) => c.id).join(', ')}');
  }
  
  // 4. Test simple notification
  try {
    await plugin.show(
      999,
      'Diagnostic Test',
      'Test notification - ${DateTime.now()}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          importance: Importance.high,
        ),
      ),
    );
    print('Test notification sent successfully');
  } catch (e) {
    print('Test notification failed: $e');
  }
}
```

#### **Common Solutions:**

**A. Permission Issues:**
```dart
Future<void> fixPermissionIssues() async {
  // Request all necessary permissions
  await Permission.notification.request();
  
  // For Android 13+
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.notification.request();
    }
  }
  
  // Guide user to settings if denied
  final status = await Permission.notification.status;
  if (status.isDenied || status.isPermanentlyDenied) {
    await openAppSettings();
  }
}
```

**B. Channel Issues:**
```dart
Future<void> recreateNotificationChannels() async {
  final plugin = FlutterLocalNotificationsPlugin();
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidPlugin != null) {
    // Delete existing channels
    await androidPlugin.deleteNotificationChannel('safe_news_channel');
    
    // Recreate with proper settings
    const channel = AndroidNotificationChannel(
      'safe_news_channel',
      'Safe News Notifications',
      description: 'Notifications for Safe News app',
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );
    
    await androidPlugin.createNotificationChannel(channel);
  }
}
```

**C. Firebase Issues:**
```dart
Future<void> reinitializeFirebase() async {
  try {
    // Get new token
    await FirebaseMessaging.instance.deleteToken();
    final newToken = await FirebaseMessaging.instance.getToken();
    
    // Save new token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', newToken ?? '');
    
    // Re-subscribe to topics
    final categories = ['breaking_news', 'sports', 'technology'];
    for (final category in categories) {
      final isSubscribed = prefs.getBool('notifications_$category') ?? false;
      if (isSubscribed) {
        await FirebaseMessaging.instance.subscribeToTopic('news_$category');
      }
    }
    
    print('Firebase reinitialized successfully');
  } catch (e) {
    print('Firebase reinitialization failed: $e');
  }
}
```

---

### **Issue 2: App crashes khi gửi notification**

#### **Symptoms:**
- App crash ngay khi send notification
- Error logs about notification details
- Crash chỉ xảy ra trên certain Android versions

#### **Solution:**
```dart
Future<void> sendNotificationSafely({
  required String title,
  required String body,
  String? payload,
}) async {
  try {
    // Use minimal, safe configuration
    const androidDetails = AndroidNotificationDetails(
      'safe_news_channel',
      'Safe News',
      channelDescription: 'Safe News notifications',
      importance: Importance.high,
      priority: Priority.high,
      // Remove potentially problematic properties
      // icon: '@mipmap/ic_launcher', // May cause issues on some devices
      enableVibration: true,
      playSound: true,
      // Don't use custom sounds or advanced features that may not be supported
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await FlutterLocalNotificationsPlugin().show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  } catch (e) {
    // Log error và fallback to basic notification
    print('Notification error: $e');
    await _sendBasicNotification(title, body);
  }
}

Future<void> _sendBasicNotification(String title, String body) async {
  try {
    // Absolute minimal configuration
    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'basic_channel',
          'Basic Notifications',
          importance: Importance.defaultImportance,
        ),
      ),
    );
  } catch (e) {
    print('Even basic notification failed: $e');
  }
}
```

---

### **Issue 3: Background processing không hoạt động**

#### **Symptoms:**
- Scheduled notifications không được gửi
- Periodic check không chạy khi app ở background
- User không nhận được notifications khi app đóng

#### **Solutions:**

**A. Android Battery Optimization:**
```dart
Future<void> handleBatteryOptimization() async {
  if (Platform.isAndroid) {
    // Check if battery optimization is disabled
    final batteryOptimized = await Permission.ignoreBatteryOptimizations.isGranted;
    
    if (!batteryOptimized) {
      // Show dialog to user
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tối ưu hóa pin'),
          content: Text(
            'Để nhận thông báo đầy đủ, vui lòng tắt tối ưu hóa pin cho Safe News'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Để sau'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Cài đặt'),
            ),
          ],
        ),
      );
      
      if (shouldRequest == true) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }
}
```

**B. iOS Background App Refresh:**
```dart
Future<void> checkiOSBackgroundRefresh() async {
  if (Platform.isIOS) {
    // Guide user to enable Background App Refresh
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Background App Refresh'),
        content: Text(
          'Để nhận thông báo khi app đóng, vui lòng bật Background App Refresh:\n\n'
          'Settings > Safe News > Background App Refresh'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đã hiểu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Mở Settings'),
          ),
        ],
      ),
    );
  }
}
```

**C. Persistent Background Service:**
```dart
Future<void> setupPersistentService() async {
  if (Platform.isAndroid) {
    // Create foreground service notification
    const androidDetails = AndroidNotificationDetails(
      'background_service',
      'Background Service',
      channelDescription: 'Keeps Safe News running for notifications',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      enableVibration: false,
      playSound: false,
      silent: true,
    );

    await FlutterLocalNotificationsPlugin().show(
      -1, // Fixed ID for persistent notification
      'Safe News đang hoạt động',
      'Đang theo dõi tin tức mới',
      NotificationDetails(android: androidDetails),
    );
  }
}
```

---

## 🔄 Maintenance Tasks

### **Daily Tasks**

#### **Monitor Notification Delivery Rate:**
```dart
Future<void> checkDailyNotificationMetrics() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  
  final sentCount = prefs.getInt('notifications_sent_$today') ?? 0;
  final deliveredCount = prefs.getInt('notifications_delivered_$today') ?? 0;
  final clickedCount = prefs.getInt('notifications_clicked_$today') ?? 0;
  
  final deliveryRate = sentCount > 0 ? (deliveredCount / sentCount) * 100 : 0;
  final clickRate = deliveredCount > 0 ? (clickedCount / deliveredCount) * 100 : 0;
  
  print('Daily Notification Metrics for $today:');
  print('Sent: $sentCount');
  print('Delivered: $deliveredCount (${deliveryRate.toStringAsFixed(1)}%)');
  print('Clicked: $clickedCount (${clickRate.toStringAsFixed(1)}%)');
  
  // Alert if delivery rate too low
  if (deliveryRate < 80 && sentCount > 10) {
    await _alertLowDeliveryRate(deliveryRate);
  }
}

Future<void> _alertLowDeliveryRate(double rate) async {
  // Send alert to development team
  await FirebaseAnalytics.instance.logEvent(
    name: 'low_notification_delivery_rate',
    parameters: {
      'delivery_rate': rate,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    },
  );
}
```

### **Weekly Tasks**

#### **Clean Up Old Data:**
```dart
Future<void> weeklyCleanup() async {
  final prefs = await SharedPreferences.getInstance();
  
  // 1. Clean up old notification history
  await _cleanupNotificationHistory();
  
  // 2. Clean up old analytics data
  await _cleanupAnalyticsData();
  
  // 3. Refresh FCM token
  await _refreshFCMToken();
  
  // 4. Verify all subscriptions
  await _verifyTopicSubscriptions();
}

Future<void> _cleanupNotificationHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final historyJson = prefs.getString('notification_history') ?? '[]';
  final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
  
  // Keep only last 100 records
  if (history.length > 100) {
    final recentHistory = history.takeLast(100).toList();
    await prefs.setString('notification_history', jsonEncode(recentHistory));
  }
  
  // Remove old daily metrics (keep only last 30 days)
  final cutoffDate = DateTime.now().subtract(Duration(days: 30));
  final keys = prefs.getKeys();
  
  for (final key in keys) {
    if (key.startsWith('notifications_') && key.contains('_202')) {
      try {
        final dateStr = key.split('_').last;
        final date = DateTime.parse('$dateStr 00:00:00');
        if (date.isBefore(cutoffDate)) {
          await prefs.remove(key);
        }
      } catch (e) {
        // Invalid date format, remove anyway
        await prefs.remove(key);
      }
    }
  }
}

Future<void> _refreshFCMToken() async {
  try {
    // Delete old token
    await FirebaseMessaging.instance.deleteToken();
    
    // Get new token
    final newToken = await FirebaseMessaging.instance.getToken();
    
    // Save new token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', newToken ?? '');
    
    print('FCM token refreshed: ${newToken?.substring(0, 20)}...');
  } catch (e) {
    print('FCM token refresh failed: $e');
  }
}
```

### **Monthly Tasks**

#### **Performance Review:**
```dart
Future<void> monthlyPerformanceReview() async {
  // 1. Generate comprehensive report
  final report = await _generatePerformanceReport();
  
  // 2. Send to analytics
  await _sendPerformanceReport(report);
  
  // 3. Optimize based on data
  await _optimizeBasedOnData(report);
}

Future<Map<String, dynamic>> _generatePerformanceReport() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1, 1);
  
  // Collect metrics for last month
  int totalSent = 0;
  int totalDelivered = 0;
  int totalClicked = 0;
  Map<String, int> categoryStats = {};
  
  for (int day = 1; day <= 31; day++) {
    final date = DateTime(lastMonth.year, lastMonth.month, day);
    if (date.month != lastMonth.month) break;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    totalSent += prefs.getInt('notifications_sent_$dateStr') ?? 0;
    totalDelivered += prefs.getInt('notifications_delivered_$dateStr') ?? 0;
    totalClicked += prefs.getInt('notifications_clicked_$dateStr') ?? 0;
  }
  
  return {
    'month': DateFormat('yyyy-MM').format(lastMonth),
    'total_sent': totalSent,
    'total_delivered': totalDelivered,
    'total_clicked': totalClicked,
    'delivery_rate': totalSent > 0 ? (totalDelivered / totalSent) * 100 : 0,
    'click_rate': totalDelivered > 0 ? (totalClicked / totalDelivered) * 100 : 0,
    'category_stats': categoryStats,
  };
}
```

---

## 🚨 Emergency Procedures

### **Complete Notification System Failure**

#### **Emergency Reset Procedure:**
```dart
Future<void> emergencyNotificationReset() async {
  print('STARTING EMERGENCY NOTIFICATION RESET');
  
  try {
    // 1. Stop all background processes
    NewsNotificationScheduler().stopPeriodicCheck();
    
    // 2. Clear all local data
    await _clearAllNotificationData();
    
    // 3. Reinitialize Firebase
    await _reinitializeFirebase();
    
    // 4. Recreate notification channels
    await _recreateAllChannels();
    
    // 5. Restore user subscriptions
    await _restoreUserSubscriptions();
    
    // 6. Restart background processes
    NewsNotificationScheduler().startPeriodicCheck();
    
    // 7. Send test notification
    await NotificationService().sendTestNotification();
    
    print('EMERGENCY RESET COMPLETED SUCCESSFULLY');
    
  } catch (e) {
    print('EMERGENCY RESET FAILED: $e');
    // Log to crash reporting
    await FirebaseCrashlytics.instance.recordError(
      e,
      StackTrace.current,
      reason: 'Emergency notification reset failed',
    );
  }
}

Future<void> _clearAllNotificationData() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Get all notification-related keys
  final keysToRemove = prefs.getKeys()
      .where((key) => key.startsWith('notification') || key.startsWith('fcm'))
      .toList();
  
  // Remove all notification data
  for (final key in keysToRemove) {
    await prefs.remove(key);
  }
  
  // Cancel all scheduled notifications
  await FlutterLocalNotificationsPlugin().cancelAll();
}

Future<void> _recreateAllChannels() async {
  final plugin = FlutterLocalNotificationsPlugin();
  final androidPlugin = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  
  if (androidPlugin != null) {
    // Delete all existing channels
    final channels = await androidPlugin.getNotificationChannels();
    if (channels != null) {
      for (final channel in channels) {
        await androidPlugin.deleteNotificationChannel(channel.id);
      }
    }
    
    // Recreate main channel
    const mainChannel = AndroidNotificationChannel(
      'safe_news_channel',
      'Safe News',
      description: 'Main notifications for Safe News',
      importance: Importance.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
    );
    
    await androidPlugin.createNotificationChannel(mainChannel);
  }
}
```

### **Production Hotfix Deployment**

#### **Hotfix Checklist:**
1. **Identify Issue**
   - [ ] Gather error logs và crash reports
   - [ ] Reproduce issue trong development
   - [ ] Assess impact scope

2. **Quick Fix**
   - [ ] Implement minimal fix
   - [ ] Test thoroughly
   - [ ] Code review (expedited)

3. **Deploy**
   - [ ] Build hotfix version
   - [ ] Test on staging
   - [ ] Deploy to production
   - [ ] Monitor deployment

4. **Verify**
   - [ ] Confirm fix works
   - [ ] Monitor error rates
   - [ ] Communicate to users if needed

#### **Hotfix Script:**
```bash
#!/bin/bash
# hotfix_deploy.sh

echo "Starting Safe News Notification Hotfix Deployment"

# 1. Checkout hotfix branch
git checkout -b hotfix/notification-urgent-fix

# 2. Apply fix
echo "Apply your fix now and press Enter to continue..."
read

# 3. Test
flutter test
if [ $? -ne 0 ]; then
    echo "Tests failed! Aborting hotfix."
    exit 1
fi

# 4. Build
flutter build apk --release
flutter build ios --release

# 5. Tag version
git add .
git commit -m "Hotfix: Emergency notification system fix"
git tag "hotfix-$(date +%Y%m%d%H%M%S)"

# 6. Deploy
echo "Manual deployment required:"
echo "1. Upload APK to Play Store"
echo "2. Upload to App Store Connect"
echo "3. Push hotfix branch"

echo "Hotfix deployment script completed"
```

---

## 📊 Monitoring Dashboard

### **Key Metrics to Monitor**

#### **Real-time Metrics:**
- Notification delivery rate (last 1h, 24h)
- Active FCM connections
- Background process health
- Error rate trends

#### **Daily Metrics:**
- Total notifications sent
- User engagement rate
- Category performance
- Device/OS breakdown

#### **Weekly Metrics:**
- User retention impact
- Notification fatigue indicators
- Performance trends
- System resource usage

### **Alert Thresholds:**

```dart
class NotificationMonitoring {
  static const double CRITICAL_DELIVERY_RATE = 70.0; // %
  static const double WARNING_DELIVERY_RATE = 85.0; // %
  static const int MAX_ERROR_COUNT_PER_HOUR = 50;
  static const double MIN_CLICK_RATE = 5.0; // %
  
  static Future<void> checkHealthMetrics() async {
    final metrics = await _getCurrentMetrics();
    
    // Check delivery rate
    if (metrics.deliveryRate < CRITICAL_DELIVERY_RATE) {
      await _sendCriticalAlert('Low delivery rate: ${metrics.deliveryRate}%');
    } else if (metrics.deliveryRate < WARNING_DELIVERY_RATE) {
      await _sendWarningAlert('Declining delivery rate: ${metrics.deliveryRate}%');
    }
    
    // Check error count
    if (metrics.errorCountLastHour > MAX_ERROR_COUNT_PER_HOUR) {
      await _sendCriticalAlert('High error count: ${metrics.errorCountLastHour}/hour');
    }
    
    // Check engagement
    if (metrics.clickRate < MIN_CLICK_RATE && metrics.totalSent > 100) {
      await _sendWarningAlert('Low engagement: ${metrics.clickRate}% click rate');
    }
  }
}
```

---

*🔧 Document này cung cấp tất cả thông tin cần thiết để troubleshoot, maintain và monitor hệ thống notification của Safe News app một cách hiệu quả!*

**📅 Version**: 1.0  
**👥 Author**: Safe News Development Team  
**📊 Last Updated**: January 16, 2025
