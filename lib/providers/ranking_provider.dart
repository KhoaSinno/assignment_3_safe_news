import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/profile/model/user_ranking_model.dart';
import 'package:assignment_3_safe_news/services/ranking_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for ranking service
final rankingServiceProvider = Provider<RankingService>((ref) {
  return RankingService();
});

// Provider for current user ranking
final currentUserRankingProvider = FutureProvider<UserRankingInfo>((ref) async {
  final authViewModel = ref.watch(authViewModelProvider);
  final rankingService = ref.watch(rankingServiceProvider);

  // Chỉ fetch ranking khi user đã đăng nhập
  if (authViewModel.user == null) {
    throw Exception('User chưa đăng nhập');
  }

  return await rankingService.getCurrentUserRanking();
});

// Provider for leaderboard (top users)
final leaderboardProvider = FutureProvider<List<UserRankingModel>>((ref) async {
  final rankingService = ref.watch(rankingServiceProvider);
  return await rankingService.getTopUsers();
});

// Notifier để refresh ranking manually
final rankingRefreshProvider =
    StateNotifierProvider<RankingRefreshNotifier, int>((ref) {
      return RankingRefreshNotifier();
    });

class RankingRefreshNotifier extends StateNotifier<int> {
  RankingRefreshNotifier() : super(0);

  void refresh() {
    state = state + 1; // Tăng counter để trigger refresh
  }
}
