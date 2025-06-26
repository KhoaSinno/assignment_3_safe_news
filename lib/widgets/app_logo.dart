import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final String? title;
  final String? subtitle;
  final double? titleFontSize;
  final double? subtitleFontSize;

  const AppLogo({
    super.key,
    this.size = 120,
    this.title = 'Safe News',
    this.subtitle = 'Đăng nhập vào tài khoản của bạn',
    this.titleFontSize = 32,
    this.subtitleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    const primaryAppColor = Color(0xFF9F224E);

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryAppColor, primaryAppColor.withValues(alpha: 0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: primaryAppColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.newspaper, size: 60, color: Colors.white),
        ),
        if (title != null) ...[
          const SizedBox(height: 24),
          Text(
            title!,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: primaryAppColor,
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: subtitleFontSize,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
