import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FontSizeOption {
  small(0.9, 'Nhỏ (14px)'),
  normal(1.0, 'Chuẩn (16px)'),
  large(1.18, 'Lớn (19px)'),
  extraLarge(1.38, 'Rất lớn (22px)');

  final double scale;
  final String label;
  const FontSizeOption(this.scale, this.label);
}

class FontSizeNotifier extends StateNotifier<FontSizeOption> {
  FontSizeNotifier() : super(FontSizeOption.normal);

  void setOption(FontSizeOption option) {
    state = option;
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, FontSizeOption>((ref) {
  return FontSizeNotifier();
});
