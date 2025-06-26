/// App constants for consistent values across the application
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double defaultRadius = 16.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 25.0;
  static const double circularRadius = 128.0;

  // Icon sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double extraLargeIconSize = 50.0;

  // Font sizes
  static const double smallFontSize = 12.0;
  static const double defaultFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 18.0;
  static const double extraLargeFontSize = 20.0;
  static const double headlineFontSize = 24.0;

  // Elevation
  static const double defaultElevation = 2.0;
  static const double highElevation = 8.0;

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Network timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Widget heights
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 120.0;
  static const double bottomNavHeight = 70.0;

  // Image dimensions
  static const double avatarSize = 60.0;
  static const double profileImageSize = 120.0;
  static const double articleImageHeight = 300.0;
  static const double thumbnailWidth = 150.0;
  static const double thumbnailHeight = 100.0;

  // Strings
  static const String appName = 'Safe News';
  static const String appTagline = 'Discover';
  static const String defaultErrorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const String noInternetMessage = 'Không có kết nối internet.';
  static const String loadingMessage = 'Đang tải...';
  static const String emptyListMessage = 'Không có dữ liệu.';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImageUrl = 'https://placehold.co/120x120';

  // Preference keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String userIdKey = 'user_id';

  // API related
  static const String baseUrl = 'https://api.example.com';
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
