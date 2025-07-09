class NotificationSettings {
  final bool isEnabled;
  final Map<String, bool> categorySubscriptions;
  final bool isLoading;

  NotificationSettings({
    required this.isEnabled,
    required this.categorySubscriptions,
    this.isLoading = false,
  });

  NotificationSettings copyWith({
    bool? isEnabled,
    Map<String, bool>? categorySubscriptions,
    bool? isLoading,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      categorySubscriptions:
          categorySubscriptions ?? this.categorySubscriptions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
