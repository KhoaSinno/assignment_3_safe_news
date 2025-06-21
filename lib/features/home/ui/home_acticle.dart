import 'package:assignment_3_safe_news/features/home/widget/article_list.dart';
import 'package:assignment_3_safe_news/features/home/widget/category_list.dart';
import 'package:assignment_3_safe_news/features/home/widget/weather_item.dart';
import 'package:assignment_3_safe_news/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class HomeArticle extends ConsumerStatefulWidget {
  const HomeArticle({super.key});

  @override
  _HomeArticleState createState() => _HomeArticleState();
}

class _HomeArticleState extends ConsumerState<HomeArticle> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Cập nhật thời gian mỗi giây
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  // Hàm lấy thứ trong tuần bằng tiếng Việt
  String getVietnameseDayOfWeek(DateTime date) {
    const List<String> daysInVietnamese = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    return daysInVietnamese[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = getVietnameseDayOfWeek(_currentTime);
    String currentDay = DateFormat('dd/MM/yyyy HH:mm').format(_currentTime);

    return Scaffold(
      body: Column(
        children: [
          // Header logo top
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
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
                Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Safe News',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: const Color(0xFF9F224E),
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'Discover',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    WeatherWidget(),
                    const SizedBox(height: 5),
                    Text(
                      'Xin chào, Anh Khoa',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    Text(
                      '$dayOfWeek, $currentDay',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFCAABB4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3F000000),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm',
                        hintStyle: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                          fontSize: 16,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                      ),
                      onChanged:
                          (value) => {
                            ref
                                .read(debouncedSearchProvider.notifier)
                                .updateSearchQuery(value),
                          },
                    ),
                  ),
                  Icon(
                    Icons.search,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Category List
          const CategoryList(),
          const SizedBox(height: 16.0),
          // Article List
          const Expanded(child: ArticleList()),
        ],
      ),
    );
  }
}
