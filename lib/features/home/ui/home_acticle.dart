import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/features/home/viewmodel/article_item_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HomeArticle extends ConsumerStatefulWidget {
  const HomeArticle({super.key});

  @override
  _HomeArticleState createState() => _HomeArticleState();
}

class _HomeArticleState extends ConsumerState<HomeArticle> {
  @override
  Widget build(BuildContext context) {
    final articleProvider = ref.watch(articleItemViewModelProvider);
    Stream<List<ArticleModel>> articles = articleProvider.fetchArticle();
    print('articles: $articles');

    return Scaffold(
      body: Column(
        children: [
          // header logo top
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEFA),
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
                      width: 35,
                      height: 35,
                      child: Icon(Icons.newspaper, color: Color(0xFF9F224E)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Safe News',
                          style: TextStyle(
                            color: Color(0xFF9F224E),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Discover',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
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
                    Row(
                      children: const [
                        Icon(Icons.wb_sunny, color: Colors.black, size: 24),
                        SizedBox(width: 5),
                        Text(
                          '32°C',
                          style: TextStyle(
                            color: Color(0xFF6D6265),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Xin chào, Anh Khoa',
                      style: TextStyle(
                        color: const Color(0xFF6D6265),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Thứ 6, 13/06/2025 09:18',
                      style: TextStyle(
                        color: const Color(0xFF231F20),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),

          // Thanh tìm kiếm
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
                color: const Color(0xFFCAABB4),
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
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFFCAABB4),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mục tin tức
          const SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xCCF5EAEA),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: const Color(0xFFCAABB4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'VNExpress',
                      style: TextStyle(
                        color: Color(0xFFCAABB4),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          // Danh mục loại bài viết
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...Categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: buildCategoryChip(
                          category['name']!,
                          isSelected:
                              category['slug'] == AppCategory.tinMoiNhat,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          // Danh sách bài viết
          Expanded(
            child: StreamBuilder<List<ArticleModel>>(
              stream: articleProvider.fetchArticle(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No articles found'));
                }
                final articles = snapshot.data!;
                return ListView.builder(
                  itemCount: articles.length,
                  padding: EdgeInsets.only(top: 0),
                  itemBuilder:
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(articles[index].imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    articles[index].title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF231F20),
                                      fontSize: 18,
                                      fontFamily: 'Aleo',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    getNameFromCategory(
                                      articles[index].category,
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF6D6265),
                                      fontSize: 14,
                                      fontFamily: 'Merriweather',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox( // Wrap the Text widget with SizedBox for full width
                                    width: double.infinity,
                                    child: Text(
                                      DateFormat('dd/MM/yyyy HH:mm')
                                          .format(articles[index].published)
                                          .toString(),
                                      textAlign: TextAlign.end, // This will now align the text to the right
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF6D6265),
                                        fontSize: 14,
                                        fontFamily: 'Merriweather',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Hồ sơ'),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Xử lý sự kiện khi người dùng nhấn vào một mục trong thanh điều hướng
        },
      ),
    );
  }
}
