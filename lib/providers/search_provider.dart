import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebouncedSearchNotifier extends StateNotifier<String?> {
  DebouncedSearchNotifier() : super(null);

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  void updateSearchQuery(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      state = null;
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      state = query;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

final debouncedSearchProvider =
    StateNotifierProvider<DebouncedSearchNotifier, String?>((ref) {
      return DebouncedSearchNotifier();
    });
