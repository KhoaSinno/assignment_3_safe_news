import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final Color? dividerColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const DividerWithText({
    super.key,
    required this.text,
    this.dividerColor,
    this.textColor,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor ?? Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor ?? Colors.grey[600],
              fontWeight: fontWeight,
              fontSize: fontSize,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor ?? Colors.grey[300])),
      ],
    );
  }
}
