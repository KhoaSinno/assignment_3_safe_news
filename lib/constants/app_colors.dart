// set color scheme for the app
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color errorColor = Color(0xFFB00020);

  static TextStyle get headline1 => GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textColor,
      );

  static TextStyle get bodyText1 => GoogleFonts.roboto(
        fontSize: 16,
        color: textColor,
      );

  static TextStyle get buttonText => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
}

// Example usage in a widget
// class ExampleWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.primaryColor,
//       child: Text(
//         'Hello, World!',
//         style: AppColors.headline1,
//       ),
//     );
//   }
//   }