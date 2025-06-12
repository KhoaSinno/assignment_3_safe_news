extension StringExtensions on String {
  // Capitalizes the first letter of the string
  String capitalize() {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }

  // Validates if the string is a valid email format
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  // Validates if the string is a valid password (at least 6 characters)
  bool isValidPassword() {
    return this.length >= 6;
  }
}

// Example usage:
// void main() {
//   String email = "abc@gmail.com ";
//   print(email.isValidEmail()); // true
//   print(email.capitalize()); // "
//   print(email.isValidPassword()); // false
//   String password = "123456";
//   print(password.isValidPassword()); // true 