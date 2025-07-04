import 'package:assignment_3_safe_news/features/bookmark/repository/bookmark_repository.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/main_screen.dart';
import 'package:assignment_3_safe_news/providers/theme_provider.dart';
import 'package:assignment_3_safe_news/theme/app_theme.dart';
import 'package:assignment_3_safe_news/utils/tts_service.dart';
import 'package:assignment_3_safe_news/utils/notification_service.dart';
import 'package:assignment_3_safe_news/utils/news_notification_scheduler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:async';
import 'firebase_options.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background messages if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình cho Android - loại bỏ padding và edge-to-edge
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, // Sử dụng edge-to-edge thay vì immersiveSticky
  );

  // Cấu hình system UI overlay style cho Android
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Load environment: 1
  await dotenv.load(fileName: ".env");

  // Initialize Firebase: 2
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler (must be before initializing)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Hive: 3
  await Hive.initFlutter();

  // Initialize bookmark repository AFTER Firebase using singleton
  await BookmarkRepository.instance.init();

  // Initialize TTS Service
  await TTSService().initialize();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize and start News Notification Scheduler
  NewsNotificationScheduler().startPeriodicCheck(
    interval: Duration(hours: 2), // Kiểm tra mỗi 2 giờ
  );

  // Setup periodic cache cleanup (every 6 hours)
  Timer.periodic(Duration(hours: 6), (timer) {
    ArticleItemRepository.clearExpiredCache();
  });

  runApp(ProviderScope(child: SafeNewsApp()));
}

class SafeNewsApp extends ConsumerWidget {
  const SafeNewsApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final authViewModel = ref.watch(authViewModelProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Safe News',
      debugShowCheckedModeBanner: false, // Ẩn debug banner
      theme: AppTheme.lightTheme.copyWith(
        // Cấu hình additional cho status bar trong light theme
        appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.dark, // Dark icons trên light theme
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        // Loại bỏ default padding
        scaffoldBackgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        // Cấu hình additional cho status bar trong dark theme
        appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.light, // Light icons trên dark theme
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        // Loại bỏ default padding
        scaffoldBackgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      ),
      themeMode: themeMode,
      // home: authViewModel.user != null ? MainScreen() : LoginScreen(),
      // Vào thẳng trang chủ
      home: const MainScreen(),
    );
  }
}
