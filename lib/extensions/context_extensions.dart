import 'package:flutter/material.dart';

/// Theme extensions for consistent styling
extension ThemeExtensions on BuildContext {
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if current theme is dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Get primary color
  Color get primaryColor => theme.primaryColor;

  /// Get surface color
  Color get surfaceColor => colorScheme.surface;

  /// Get background color
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  /// Get error color
  Color get errorColor => colorScheme.error;

  /// Get success color (green)
  Color get successColor => Colors.green;

  /// Get warning color (orange)
  Color get warningColor => Colors.orange;
}

/// MediaQuery extensions for responsive design
extension MediaQueryExtensions on BuildContext {
  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is tablet (width > 600)
  bool get isTablet => screenWidth > 600;

  /// Check if device is mobile (width <= 600)
  bool get isMobile => screenWidth <= 600;

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  /// Get keyboard height
  double get keyboardHeight => mediaQuery.viewInsets.bottom;

  /// Check if keyboard is open
  bool get isKeyboardOpen => keyboardHeight > 0;
}

/// Navigator extensions for easier navigation
extension NavigatorExtensions on BuildContext {
  /// Push new route
  Future<T?> push<T>(Widget page) {
    return Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => page));
  }

  /// Push and replace current route
  Future<T?> pushReplacement<T>(Widget page) {
    return Navigator.of(
      this,
    ).pushReplacement<T, void>(MaterialPageRoute(builder: (_) => page));
  }

  /// Push and remove all previous routes
  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  /// Pop current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();
}
