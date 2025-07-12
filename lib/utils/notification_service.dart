import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _requestPermissions();
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();

    _isInitialized = true;
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request notification permission
    final permission = await Permission.notification.request();
    if (!permission.isGranted) {
      return;
    }

    // Request Firebase messaging permission
    final settings = await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher_monochrome', // Sử dụng monochrome cho Android 13+
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Tạo notification channel cho Android
    await _createNotificationChannel();
  }

  /// Tạo notification channel cho Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'safe_news_channel',
      'Safe News Notifications',
      description: 'Thông báo tin tức từ ứng dụng Safe News',
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToStorage(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToStorage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle app opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationEnabled =
        prefs.getBool('notifications_enabled') ?? true;

    if (!isNotificationEnabled) return;

    await _showLocalNotification(
      title: message.notification?.title ?? 'Tin tức mới',
      body: message.notification?.body ?? 'Có bài báo mới cập nhật',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    // Navigate to specific article if URL is provided
    final url = message.data['url'];
    if (url != null) {
      // TODO: Navigate to article detail
      // You can use GoRouter to navigate to the article
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final url = data['url'];
        if (url != null) {
          // TODO: Navigate to article detail
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  /// Show notification (public method)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(title: title, body: body, payload: payload);
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = const AndroidNotificationDetails(
      'safe_news_channel',
      'Safe News',
      channelDescription: 'Thông báo tin tức từ Safe News',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher', // Thử dùng icon gốc thay vì monochrome
      largeIcon: DrawableResourceAndroidBitmap(
        '@mipmap/ic_launcher',
      ), // Large icon (app logo)
      color: Color(0xFF1976D2), // Màu xanh dương
      autoCancel: true,
      enableLights: true,
      enableVibration: true,
      showWhen: true,
      channelShowBadge: true,
      // Đơn giản hóa - không dùng BigPictureStyle
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: 'Safe News',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Save FCM token to local storage
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);

    if (enabled) {
      await subscribeToTopic('news_updates');
    } else {
      await unsubscribeFromTopic('news_updates');
    }
  }

  /// Get notification categories for settings
  List<String> getNotificationCategories() {
    return [
      'breaking_news',
      'sports',
      'technology',
      'business',
      'entertainment',
      'health',
      'science',
    ];
  }

  /// Subscribe to category
  Future<void> subscribeToCategoryNotifications(
    String category,
    bool subscribe,
  ) async {
    final topic = 'news_$category';
    if (subscribe) {
      await subscribeToTopic(topic);
    } else {
      await unsubscribeFromTopic(topic);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_$category', subscribe);
  }

  /// Check if subscribed to category
  Future<bool> isSubscribedToCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_$category') ?? true;
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Safe News - Test',
      body: 'Đây là thông báo thử nghiệm từ ứng dụng Safe News',
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages if needed
}
