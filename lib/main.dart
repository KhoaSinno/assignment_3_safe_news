import 'package:assignment_3_safe_news/features/bookmark/repository/bookmark_repository.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/main_screen.dart';
import 'package:assignment_3_safe_news/providers/theme_provider.dart';
import 'package:assignment_3_safe_news/theme/app_theme.dart';
import 'package:assignment_3_safe_news/utils/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:async';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cấu hình ẩn thanh trạng thái và thanh điều hướng
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky, // Ẩn hoàn toàn status bar và navigation bar
  );

  // Hoặc nếu muốn chỉ ẩn status bar mà giữ navigation bar:
  // SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.manual,
  //   overlays: [SystemUiOverlay.bottom], // Chỉ hiển thị navigation bar
  // );

  // Load environment: 1
  await dotenv.load(fileName: ".env");

  // Initialize Firebase: 2
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive: 3
  await Hive.initFlutter();

  // Initialize bookmark repository AFTER Firebase using singleton
  await BookmarkRepository.instance.init();

  // Initialize TTS Service
  await TTSService().initialize();

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
      theme: AppTheme.lightTheme.copyWith(
        // Cấu hình additional cho status bar trong light theme
        appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.dark, // Dark icons trên light theme
            systemNavigationBarColor: Colors.transparent,
          ),
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        // Cấu hình additional cho status bar trong dark theme
        appBarTheme: AppTheme.darkTheme.appBarTheme.copyWith(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Transparent status bar
            statusBarIconBrightness:
                Brightness.light, // Light icons trên dark theme
            systemNavigationBarColor: Colors.transparent,
          ),
        ),
      ),
      themeMode: themeMode,
      // home: authViewModel.user != null ? MainScreen() : LoginScreen(),
      // Vào thẳng trang chủ
      home: MainScreen(),
    );
  }
}
