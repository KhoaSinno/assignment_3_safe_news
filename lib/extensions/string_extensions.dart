/// String extensions for common operations
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  /// Returns the original string if empty
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Validates if the string is a valid email format
  /// Returns true if the string matches email pattern
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(trim());
  }

  /// Validates if the string is a valid password
  /// Password must be at least 6 characters long
  bool isValidPassword() {
    return trim().length >= 6;
  }

  /// Removes all whitespace and returns trimmed string
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Checks if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Checks if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Truncates string to specified length and adds ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}
