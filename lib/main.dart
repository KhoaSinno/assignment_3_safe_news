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

  try {
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

    // Load environment: 1 (với error handling)
    try {
      await dotenv.load();
    } catch (e) {
      print('Warning: .env file not found or failed to load: $e');
      // Tiếp tục chạy app mà không có .env file
    }

    // Initialize Firebase: 2
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler (must be before initializing)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize Hive: 3
    await Hive.initFlutter();

    // Initialize bookmark repository AFTER Firebase using singleton
    try {
      await BookmarkRepository.instance.init();
    } catch (e) {
      print('Warning: BookmarkRepository initialization failed: $e');
    }

    // Initialize TTS Service
    try {
      await TTSService().initialize();
    } catch (e) {
      print('Warning: TTS Service initialization failed: $e');
    }

    // Initialize Notification Service
    try {
      await NotificationService().initialize();
    } catch (e) {
      print('Warning: Notification Service initialization failed: $e');
    }

    // Initialize and start News Notification Scheduler
    try {
      NewsNotificationScheduler().startPeriodicCheck(
        interval: const Duration(hours: 2), // Kiểm tra mỗi 2 giờ
      );
    } catch (e) {
      print('Warning: News Notification Scheduler failed: $e');
    }

    // Setup periodic cache cleanup (every 6 hours)
    Timer.periodic(const Duration(hours: 6), (timer) {
      try {
        ArticleItemRepository.clearExpiredCache();
      } catch (e) {
        print('Warning: Cache cleanup failed: $e');
      }
    });

    runApp(const ProviderScope(child: SafeNewsApp()));
  } catch (error, stackTrace) {
    print('Error during app initialization: $error');
    print('Stack trace: $stackTrace');

    // Chạy app với minimal setup nếu có lỗi
    runApp(const ProviderScope(child: SafeNewsApp()));
  }
}

class SafeNewsApp extends ConsumerWidget {
  const SafeNewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
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
        // Thêm error widget để bắt lỗi
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 50),
                    const SizedBox(height: 16),
                    const Text(
                      'Có lỗi xảy ra!',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorDetails.exception.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          };
          return child!;
        },
      );
    } catch (e) {
      print('Error in SafeNewsApp build: $e');
      // Fallback widget nếu có lỗi
      return const MaterialApp(
        title: 'Safe News',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                SizedBox(height: 16),
                Text(
                  'App đang khởi tạo...',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }
  }
}
