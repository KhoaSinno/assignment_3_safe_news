import 'package:flutter/widgets.dart';

/// Hàm helper để xác định loại ImageProvider
ImageProvider getImageProvider(dynamic widget) {
  final String? imageUrl = widget.article.imageUrl;

  // Kiểm tra nếu imageUrl null, empty hoặc là "N/A"
  if (imageUrl == null || imageUrl.isEmpty || imageUrl.toLowerCase() == 'n/a') {
    return const AssetImage('assets/default_images/default_news_image.png');
  }

  // Nếu là URL hợp lệ, dùng NetworkImage
  return NetworkImage(imageUrl);
}
