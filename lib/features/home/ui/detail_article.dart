import 'dart:ui';
// APP
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/utils/article_parser.dart';
// PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
// File import
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';

class DetailArticle extends StatefulWidget {
  const DetailArticle({super.key, required this.article});
  final ArticleModel article;

  @override
  _DetailArticleState createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  String? _summary;
  bool _isLoadingSummary = false;
  String? _articleHtmlContent;
  bool _isLoadingArticle = false;

  @override
  void initState() {
    super.initState();
    _loadArticleAndGenerateSummary();
  }

  Future<void> _loadArticleAndGenerateSummary() async {
    if (mounted) {
      setState(() {
        _isLoadingArticle = true;
        _isLoadingSummary = true;
      });
    }

    try {
      final fetchedHtmlContent = await fetchArticleContent(
        url: widget.article.link,
      );
      if (mounted) {
        setState(() {
          _articleHtmlContent = fetchedHtmlContent;
          _isLoadingArticle = false;
        });
      }

      final plainTextContent = extractTextFromHtml(fetchedHtmlContent);
      if (plainTextContent.isNotEmpty) {
        final summary = await ArticleItemRepository.summaryContentGemini(
          plainTextContent,
        );
        if (mounted) {
          setState(() {
            _summary = summary;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _summary = "Không thể trích xuất nội dung để tóm tắt.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_isLoadingArticle) {
            _articleHtmlContent = "<p>Lỗi khi tải nội dung: $e</p>";
          }
          _summary = "Lỗi khi xử lý bài viết: $e";
          _isLoadingArticle = false;
        });
      }
      print('Error loading article or generating summary: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false; // Ensure summary loading is set to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        // Use Stack to layer blur effect and content, isn't work
        children: [
          // Frosted glass effect, isn't work
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.article.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                  child:
                      widget.article.imageUrl.isEmpty ||
                              Uri.tryParse(
                                    widget.article.imageUrl,
                                  )?.hasAbsolutePath !=
                                  true
                          ? Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                          : null,
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          // CircleAvatar(
                          //   radius: 12,
                          //   backgroundImage: NetworkImage(
                          //     "https://placehold.co/24x24",
                          //   ),
                          // ),
                          // SizedBox(width: 8),
                          Text(
                            // 'Anh Khoa · Thứ 3 ngày 10 năm 2025',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(widget.article.published).toString(),
                            style: TextStyle(
                              color: const Color(0xFF6D6265),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            'Bản tóm tắt',
                            style: TextStyle(
                              color: const Color(0xFF231F20),
                              fontSize: 20,
                              fontFamily: 'Aleo',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          _isLoadingSummary
                              ? SizedBox()
                              : IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.volume_up),
                              ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _isLoadingSummary
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                            _summary ?? 'Đang tải tóm tắt...',
                            style: TextStyle(
                              color: const Color(0xFF231F20),
                              fontSize: 16,
                              fontFamily: 'Merriweather',
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                      SizedBox(height: 24),
                      Text(
                        'Chi tiết bài báo',
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 20,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      _isLoadingArticle
                          ? Center(child: CircularProgressIndicator())
                          : HtmlWidget(
                            _articleHtmlContent ?? '<p>Không có nội dung.</p>',
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
