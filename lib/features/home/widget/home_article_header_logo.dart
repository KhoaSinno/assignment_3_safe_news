import 'package:assignment_3_safe_news/constants/app_calendar.dart';
import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/widget/weather_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeArticleHeaderLogo extends ConsumerWidget {
  const HomeArticleHeaderLogo({super.key, required this.currentTime});
  final DateTime currentTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dayOfWeek = getVietnameseDayOfWeek(currentTime);
    String currentDay = DateFormat('dd/MM/yyyy HH:mm').format(currentTime);
    final authViewModel = ref.watch(authViewModelProvider);
    final isLoggedIn = authViewModel.user != null;

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Row(
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: Icon(
                    Icons.newspaper,
                    color: Color(0xFF9F224E),
                    size: 50,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Safe News',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(
                          color: const Color(0xFF9F224E),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                      Text(
                        'Discover',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [WeatherWidget()],
                ),
                const SizedBox(height: 5),
                isLoggedIn
                    ? Text(
                      'Xin chào, ${authViewModel.user?.name ?? 'Người dùng'}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    )
                    : Text(
                      'Càng đọc càng vui!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                Text(
                  '$dayOfWeek, $currentDay',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
