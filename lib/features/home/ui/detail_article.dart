// cspell:disable
import 'dart:async';
// APP
import 'package:assignment_3_safe_news/features/authentication/ui/login_screen.dart';
import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/providers/user_stats_provider.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/utils/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
// PACKAGES
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DetailArticle extends ConsumerStatefulWidget {
  const DetailArticle({super.key, required this.article});
  final ArticleModel article;

  @override
  ConsumerState<DetailArticle> createState() => _DetailArticleState();
}

class _DetailArticleState extends ConsumerState<DetailArticle> {
  String? _summary;
  bool _isLoadingSummary = false;
  String? _articleHtmlContent;
  bool _isLoadingArticle = false;
  String _plainTextContent = '';
  bool _isPressingBrief = false;
  bool _isPressingFull = false;

  // Tracking user reading article
  Timer? _readingTimer;
  int _seconds = 0;
  bool _hasTracking = false;

  final FlutterTts flutterTts = FlutterTts();
  @override
  void initState() {
    super.initState();
    _loadArticleAndGenerateSummary();
    _startReadingTimer();
  }

  void _startReadingTimer() {
    if (FirebaseAuth.instance.currentUser == null) return;

    _readingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
        if (_seconds >= 60 && !_hasTracking) {
          _hasTracking = true;

          _onReadCompleted();
          _readingTimer?.cancel();
          _readingTimer = null;
        }
      }
    });
  }

  // Call riverpod to update info
  void _onReadCompleted() {
    final userStatsNotifier = ref.read(userStatsNotifierProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    userStatsNotifier.incrementArticleRead(
      category: widget.article.category,
      readingTimeSeconds: _seconds,
      user: user,
      context: context, // Truyền context để hiển thị toast
    );
  }

  Future<void> _loadArticleAndGenerateSummary() async {
    if (mounted) {
      setState(() {
        _isLoadingArticle = true;
        _isLoadingSummary = true;
      });
    }

    try {
      // Sử dụng cached content fetching
      final fetchedHtmlContent =
          await ArticleItemRepository.getContentWithCache(widget.article.link);
      if (mounted) {
        setState(() {
          _articleHtmlContent = fetchedHtmlContent;
          _isLoadingArticle = false;
        });
      }

      final plainTextContent = extractTextFromHtml(fetchedHtmlContent);
      if (plainTextContent.isNotEmpty) {
        _plainTextContent = plainTextContent;
        // Sử dụng cached summary generation
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
            _summary = 'Không thể trích xuất nội dung để tóm tắt.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_isLoadingArticle) {
            _articleHtmlContent = '<p>Lỗi khi tải nội dung: $e</p>';
          }
          _summary = 'Lỗi khi xử lý bài viết: $e';
          _isLoadingArticle = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    // Kiểm tra trạng thái đăng nhập trước
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng đăng nhập để lưu bài viết'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Đăng nhập',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
        );
      }
      return;
    }

    final bookmarkViewModel = ref.read(bookmarkProvider);

    try {
      final bookmark = BookmarkModel(
        id: widget.article.id,
        title: widget.article.title,
        imageUrl: widget.article.imageUrl,
        link: widget.article.link!,
        published: widget.article.published,
        summary: _summary ?? 'Chưa có tóm tắt',
        htmlContent: _articleHtmlContent ?? '',
        plainTextContent: _plainTextContent,
        bookmarkedAt: DateTime.now(),
      );

      await bookmarkViewModel.toggleBookmark(bookmark);

      final isBookmarked = bookmarkViewModel.isBookmarked(widget.article.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBookmarked
                  ? 'Đã bookmark bài viết "${widget.article.title}"'
                  : 'Đã bỏ bookmark bài viết "${widget.article.title}"',
            ),
            backgroundColor: isBookmarked ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi khi cập nhật bookmark: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                final String shareText =
                    widget.article.link != null &&
                            widget.article.link!.isNotEmpty
                        ? 'Check out this article: ${widget.article.title}\n\n${widget.article.link}'
                        : 'Check out this article: ${widget.article.title}';

                await SharePlus.instance.share(ShareParams(text: shareText));

                if (!mounted) return;
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Chia sẻ thành công!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // Silently handle error or log it
                // showDialog removed to avoid async context issues
              }
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final user = FirebaseAuth.instance.currentUser;
              final bookmarkViewModel = ref.watch(bookmarkProvider);
              final isBookmarked = bookmarkViewModel.isBookmarked(
                widget.article.id,
              );

              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color:
                      user == null
                          ? Colors
                              .grey // Màu xám khi chưa đăng nhập
                          : isBookmarked
                          ? Colors.blue
                          : Theme.of(context).iconTheme.color,
                ),
                onPressed: _toggleBookmark,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: getImageProvider(widget),
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
                      ? const Center(
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(
                    widget.article.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 24,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      // 'Anh Khoa · Thứ 3 ngày 10 năm 2025',
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(widget.article.published).toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                            ? const SizedBox()
                            : IconButton(
                              onPressed: () {
                                setState(() {
                                  // Nếu đang đọc summary, toggle nó
                                  // Nếu không đang đọc summary, tắt full và bật summary
                                  if (_isPressingBrief) {
                                    _isPressingBrief = false;
                                    flutterTts.stop();
                                  } else {
                                    _isPressingBrief = true;
                                    _isPressingFull = false;
                                    flutterTts.stop();
                                    flutterTts.setLanguage('vi-VN');
                                    flutterTts.speak(
                                      _summary ??
                                          'Đang có lỗi xảy ra với văn bản tóm tắt! Xin vui lòng thử lại!',
                                    );
                                  }
                                });
                              },
                              icon: const Icon(Icons.volume_up),
                              iconSize: 40,
                              color:
                                  _isPressingBrief
                                      ? const Color.fromARGB(255, 44, 8, 204)
                                      : Theme.of(context).iconTheme.color
                                          ?.withValues(alpha: 0.54),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingSummary
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                  const SizedBox(height: 24),
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
                            ? const SizedBox()
                            : IconButton(
                              onPressed: () {
                                setState(() {
                                  // Nếu đang đọc full content, toggle nó
                                  // Nếu không đang đọc full content, tắt summary và bật full content
                                  if (_isPressingFull) {
                                    _isPressingFull = false;
                                    flutterTts.stop();
                                  } else {
                                    _isPressingFull = true;
                                    _isPressingBrief = false;
                                    flutterTts.stop();
                                    flutterTts.setLanguage('vi-VN');
                                    flutterTts.speak(_plainTextContent);
                                  }
                                });
                              },
                              icon: const Icon(Icons.volume_up),
                              iconSize: 40,
                              color:
                                  _isPressingFull
                                      ? const Color.fromARGB(255, 44, 8, 204)
                                      : Theme.of(context).iconTheme.color
                                          ?.withValues(alpha: 0.54),
                            ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingArticle
                      ? const Center(child: CircularProgressIndicator())
                      : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: HtmlWidget(
                          _articleHtmlContent ?? '<p>Không có nội dung.</p>',
                          textStyle: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            fontFamily: 'Merriweather',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
    );
  }
}
