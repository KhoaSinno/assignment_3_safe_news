import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PerformanceOptimizer {
  static void initializeOptimizations() {
    // Tối ưu garbage collection
    if (!kDebugMode) {
      // Disable debug prints in release mode
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    // Tối ưu system UI
    _optimizeSystemUI();
  }

  static void _optimizeSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  static void optimizeScrolling() {
    // Có thể thêm các tối ưu scroll performance
  }

  static void preloadCriticalAssets() {
    // Preload các assets quan trọng
  }

  static void optimizeImageCache() {
    // Tối ưu image cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  static void clearMemoryCache() {
    // Clear memory cache khi cần
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
