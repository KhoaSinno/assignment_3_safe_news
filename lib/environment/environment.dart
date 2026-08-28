import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Configuration and Environment Settings for Safe News Mobile App.
/// All environment variables and application constants must be accessed through this class.
class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  static bool _isInitialized = false;

  /// Indicates if environment variables have been successfully initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize environment configuration from `.env` file.
  /// Falls back gracefully if `.env` is missing or fails to load.
  static Future<void> init({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      // Graceful fallback - default constants will be used
    }
  }

  // =========================================================================
  // 🤖 Gemini AI Configuration
  // =========================================================================

  /// Gemini API Key
  static String get geminiApiKey =>
      dotenv.env['GEMINI_KEY']?.trim() ?? '';

  /// Gemini Model Name (Default: gemini-2.5-flash)
  static String get geminiModel =>
      dotenv.env['GEMINI_MODEL']?.trim() ?? 'gemini-2.5-flash';

  /// Check if a valid Gemini API key is configured
  static bool get hasValidGeminiKey =>
      geminiApiKey.isNotEmpty && !geminiApiKey.startsWith('YOUR_');

  // =========================================================================
  // 🌤️ Weather API Configuration
  // =========================================================================

  /// OpenWeatherMap API Key
  static String get weatherApiKey =>
      dotenv.env['WEATHER_API_KEY']?.trim() ?? '';

  /// OpenWeatherMap API Base URL
  static String get weatherBaseUrl =>
      dotenv.env['WEATHER_BASE_URL']?.trim() ??
      'https://api.openweathermap.org/data/2.5';

  /// Check if a valid Weather API key is configured
  static bool get hasValidWeatherKey =>
      weatherApiKey.isNotEmpty &&
      weatherApiKey != 'YOUR_OPENWEATHERMAP_API_KEY';

  // =========================================================================
  // 🔥 Firebase Firestore Collection Names
  // =========================================================================

  /// Main collection for positive/safe news articles
  static String get newsCollection =>
      dotenv.env['FIRESTORE_NEWS_COLLECTION']?.trim() ?? 'positive_news';

  /// Collection for user reports and feedback
  static String get reportsCollection =>
      dotenv.env['FIRESTORE_REPORTS_COLLECTION']?.trim() ?? 'news_reports';
}
