// Provider for notification settings
import 'package:assignment_3_safe_news/features/profile/model/notification_settings.dart';
import 'package:assignment_3_safe_news/utils/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((
      ref,
    ) {
      return NotificationSettingsNotifier();
    });

// Đây là "control panel" - nơi user bật/tắt các loại thông báo
// State chứa:
// - isEnabled: Có bật thông báo không?
// - categorySubscriptions: Map<String, bool> - Subscribe category nào?
// - isLoading: Đang xử lý không?
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final NotificationService _notificationService = NotificationService();

  NotificationSettingsNotifier()
    : super(NotificationSettings(isEnabled: true, categorySubscriptions: {})) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = state.copyWith(isLoading: true);

    try {
      final isEnabled = await _notificationService.areNotificationsEnabled();
      final categories = _notificationService.getNotificationCategories();
      final categorySubscriptions = <String, bool>{};

      for (final category in categories) {
        categorySubscriptions[category] = await _notificationService
            .isSubscribedToCategory(category);
      }

      state = NotificationSettings(
        isEnabled: isEnabled,
        categorySubscriptions: categorySubscriptions,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(isLoading: true);

    try {
      await _notificationService.setNotificationsEnabled(enabled);
      state = state.copyWith(isEnabled: enabled, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleCategorySubscription(
    String category,
    bool subscribe,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      await _notificationService.subscribeToCategoryNotifications(
        category,
        subscribe,
      );
      final updatedSubscriptions = Map<String, bool>.from(
        state.categorySubscriptions,
      );
      updatedSubscriptions[category] = subscribe;

      state = state.copyWith(
        categorySubscriptions: updatedSubscriptions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendTestNotification() async {
    await _notificationService.sendTestNotification();
  }
}
