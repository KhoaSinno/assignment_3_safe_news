import 'dart:developer' as developer;

/// App Logger utility for consistent logging across the application
class AppLogger {
  static const String _defaultTag = 'SafeNews';

  /// Log debug information
  static void debug(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 700, // DEBUG
    );
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 800, // INFO
    );
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 900, // WARNING
    );
  }

  /// Log error messages
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000, // SEVERE
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log network requests
  static void network(String message, {String? tag}) {
    developer.log(message, name: '${tag ?? _defaultTag}-Network', level: 800);
  }

  /// Log authentication events
  static void auth(String message, {String? tag}) {
    developer.log(message, name: '${tag ?? _defaultTag}-Auth', level: 800);
  }
}
