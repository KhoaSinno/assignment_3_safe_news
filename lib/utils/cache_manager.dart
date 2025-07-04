import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CacheManager {
  static const String _cachePrefix = 'cache_';
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const Duration _cacheExpiry = Duration(days: 7);

  static Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final timestampKey = '${key}_timestamp';
          final timestamp = prefs.getInt(timestampKey);

          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            if (now.difference(cacheTime) > _cacheExpiry) {
              await prefs.remove(key);
              await prefs.remove(timestampKey);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing expired cache: $e');
    }
  }

  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
          await prefs.remove('${key}_timestamp');
        }
      }
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  static Future<void> manageCacheSize() async {
    try {
      // Clear expired cache first
      await clearExpiredCache();

      // Check app cache directory size
      final cacheDir = Directory.systemTemp;
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      // If cache is too large, clear some of it
      if (totalSize > _maxCacheSize) {
        await clearAllCache();
      }
    } catch (e) {
      debugPrint('Error managing cache size: $e');
    }
  }

  static Future<void> setCacheData(String key, String data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '${cacheKey}_timestamp';

      await prefs.setString(cacheKey, data);
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error setting cache data: $e');
    }
  }

  static Future<String?> getCacheData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final timestampKey = '${cacheKey}_timestamp';

      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          await prefs.remove(cacheKey);
          await prefs.remove(timestampKey);
          return null;
        }
      }

      return prefs.getString(cacheKey);
    } catch (e) {
      debugPrint('Error getting cache data: $e');
      return null;
    }
  }
}
