import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider để quản lý badge đã chọn
final selectedBadgeProvider =
    StateNotifierProvider<SelectedBadgeNotifier, Achievement?>((ref) {
      return SelectedBadgeNotifier();
    });

class SelectedBadgeNotifier extends StateNotifier<Achievement?> {
  SelectedBadgeNotifier() : super(null) {
    _loadSelectedBadge();
  }

  static const String _selectedBadgeKey = 'selected_badge';

  // Load badge đã chọn từ SharedPreferences
  Future<void> _loadSelectedBadge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final badgeName = prefs.getString(_selectedBadgeKey);

      if (badgeName != null) {
        // Chuyển đổi string thành Achievement enum
        final achievement = Achievement.values.firstWhere(
          (a) => a.name == badgeName,
          orElse: () => Achievement.newbie,
        );
        state = achievement;
      }
    } catch (e) {
      // Nếu có lỗi, set về null
      state = null;
    }
  }

  // Chọn badge mới
  Future<void> selectBadge(Achievement achievement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedBadgeKey, achievement.name);
      state = achievement;
    } catch (e) {
      // Xử lý lỗi nếu cần
      rethrow;
    }
  }

  // Xóa badge đã chọn (về mặc định)
  Future<void> clearSelectedBadge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedBadgeKey);
      state = null;
    } catch (e) {
      // Xử lý lỗi nếu cần
      rethrow;
    }
  }
}
