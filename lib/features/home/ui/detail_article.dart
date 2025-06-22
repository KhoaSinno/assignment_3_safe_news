import 'dart:ui';
// APP
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/utils/article_parser.dart';
// PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
  String _plainTextContent = '';
  bool _isPressingBrief = false;
  bool _isPressingFull = false;

  final FlutterTts flutterTts = FlutterTts();

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
        _plainTextContent = plainTextContent;
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
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).iconTheme.color),
            onPressed: () async {
              try {
                final String shareText =
                    widget.article.link != null &&
                            widget.article.link!.isNotEmpty
                        ? 'Check out this article: ${widget.article.title}\n\n${widget.article.link}'
                        : 'Check out this article: ${widget.article.title}';

                await Share.share(shareText);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Chia sẻ thành công!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  final String shareText =
                      widget.article.link != null &&
                              widget.article.link!.isNotEmpty
                          ? 'Check out this article: ${widget.article.title}\n\n${widget.article.link}'
                          : 'Check out this article: ${widget.article.title}';

                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Nội dung chia sẻ'),
                          content: SelectableText(shareText),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Đóng'),
                            ),
                          ],
                        ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Theme.of(context).iconTheme.color,
            ),
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.article.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 24, fontFamily: 'Inter'),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          // 'Anh Khoa · Thứ 3 ngày 10 năm 2025',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(widget.article.published).toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Bản tóm tắt',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 20, fontFamily: 'Aleo'),
                            ),
                            _isLoadingSummary
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPressingBrief = !_isPressingBrief;
                                    });
                                    if (_isPressingBrief) {
                                      flutterTts.setLanguage('vi-VN');
                                      flutterTts.speak(
                                        _summary ??
                                            'Đang có lỗi xảy ra với văn bản tóm tắt! Xin vui lòng thử lại!',
                                      );
                                    }
                                    if (!_isPressingBrief) {
                                      flutterTts.stop();
                                    }
                                  },
                                  icon: Icon(Icons.volume_up),
                                  iconSize: 40,
                                  color:
                                      _isPressingBrief
                                          ? const Color.fromARGB(
                                            255,
                                            44,
                                            8,
                                            204,
                                          )
                                          : Theme.of(
                                            context,
                                          ).iconTheme.color?.withOpacity(0.54),
                                ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      _isLoadingSummary
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Text(
                              _summary ?? 'Đang tải tóm tắt...',
                              textAlign: TextAlign.justify,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontFamily: 'Merriweather',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                      SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chi tiết bài báo',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 20, fontFamily: 'Aleo'),
                            ),
                            _isLoadingArticle
                                ? SizedBox()
                                : IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPressingFull = !_isPressingFull;
                                    });
                                    if (_isPressingFull) {
                                      flutterTts.setLanguage('vi-VN');
                                      flutterTts.speak(_plainTextContent);
                                    }
                                    if (!_isPressingFull) {
                                      flutterTts.stop();
                                    }
                                  },
                                  icon: Icon(Icons.volume_up),
                                  iconSize: 40,
                                  color:
                                      _isPressingFull
                                          ? const Color.fromARGB(
                                            255,
                                            44,
                                            8,
                                            204,
                                          )
                                          : Theme.of(
                                            context,
                                          ).iconTheme.color?.withOpacity(0.54),
                                ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      _isLoadingArticle
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: HtmlWidget(
                              _articleHtmlContent ??
                                  '<p>Không có nội dung.</p>',
                              textStyle: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                fontFamily: 'Merriweather',
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                              ),
                              customStylesBuilder: (element) {
                                if (element.localName == 'p') {
                                  return {
                                    'text-align': 'justify',
                                    'line-height': '1.6',
                                    'margin-bottom': '16px',
                                  };
                                }
                                if (element.localName == 'div') {
                                  return {
                                    'text-align': 'justify',
                                    'line-height': '1.6',
                                  };
                                }
                                if (element.localName == 'h1' ||
                                    element.localName == 'h2' ||
                                    element.localName == 'h3') {
                                  return {
                                    'text-align': 'center',
                                    'margin': '20px 0 16px 0',
                                    'font-weight': 'bold',
                                  };
                                }
                                return null;
                              },
                            ),
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
