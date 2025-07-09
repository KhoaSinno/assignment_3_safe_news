import 'package:assignment_3_safe_news/features/home/widget/article_list.dart';
import 'package:assignment_3_safe_news/features/home/widget/category_list.dart';
import 'package:assignment_3_safe_news/features/home/widget/home_article_header_logo.dart';
import 'package:assignment_3_safe_news/features/home/widget/home_article_search.dart';
import 'package:assignment_3_safe_news/features/home/widget/home_article_sort_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class HomeArticle extends ConsumerStatefulWidget {
  const HomeArticle({super.key});

  @override
  ConsumerState<HomeArticle> createState() => _HomeArticleState();
}

class _HomeArticleState extends ConsumerState<HomeArticle> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Cập nhật thời gian mỗi phút thay vì mỗi giây để giảm lag
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy timer khi widget bị dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header logo top
          HomeArticleHeaderLogo(currentTime: _currentTime),
          const SizedBox(height: 16.0),
          // Search bar
          const HomeArticleSearch(),
          const SizedBox(height: 16.0),
          // Category List
          const CategoryList(),
          const SizedBox(height: 16.0),
          // Dropdown for sorting time articles:
          const HomeArticleSortTime(),
          const SizedBox(height: 16.0),
          // Article List
          const Expanded(child: ArticleList()),
        ],
      ),
    );
  }
}
