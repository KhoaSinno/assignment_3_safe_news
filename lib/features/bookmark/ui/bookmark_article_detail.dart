// cspell:disable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:ui';
// APP
import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
// PACKAGES
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class BookmarkArticleDetail extends ConsumerStatefulWidget {
  const BookmarkArticleDetail({super.key, required this.bookmark});
  final BookmarkModel bookmark;

  @override
  ConsumerState<BookmarkArticleDetail> createState() =>
      _BookmarkArticleDetailState();
}

class _BookmarkArticleDetailState extends ConsumerState<BookmarkArticleDetail> {
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
    _loadBookmarkData();
  }

  Future<void> _loadBookmarkData() async {
    // Sử dụng dữ liệu đã lưu trong bookmark thay vì tải từ web
    if (mounted) {
      setState(() {
        _summary = widget.bookmark.summary;
        _articleHtmlContent = widget.bookmark.htmlContent;
        _plainTextContent = widget.bookmark.plainTextContent;
        _isLoadingSummary = false;
        _isLoadingArticle = false;
      });
    }
  }

  Future<void> _toggleBookmark() async {
    final bookmarkViewModel = ref.read(bookmarkProvider);

    try {
      await bookmarkViewModel.removeBookmark(widget.bookmark.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã bỏ bookmark bài viết "${widget.bookmark.title}"'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        // Return true để báo hiệu bookmark đã bị xóa
        Navigator.pop(context, true);
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
                    widget.bookmark.link.isNotEmpty
                        ? 'Check out this article: ${widget.bookmark.title}\n\n${widget.bookmark.link}'
                        : 'Check out this article: ${widget.bookmark.title}';

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
              return IconButton(
                icon: const Icon(
                  Icons
                      .bookmark, // Luôn hiển thị bookmark filled vì đây là trang bookmark
                  color: Colors.blue,
                ),
                onPressed: _toggleBookmark,
              );
            },
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
              child: Container(color: Colors.black.withValues(alpha: 0.1)),
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
                      image: NetworkImage(widget.bookmark.imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                  child:
                      widget.bookmark.imageUrl.isEmpty ||
                              Uri.tryParse(
                                    widget.bookmark.imageUrl,
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
                        widget.bookmark.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontSize: 24, fontFamily: 'Inter'),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          // 'Anh Khoa · Thứ 3 ngày 10 năm 2025',
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(widget.bookmark.published).toString(),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
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
                                  icon: const Icon(Icons.volume_up),
                                  iconSize: 40,
                                  color:
                                      _isPressingBrief
                                          ? const Color.fromARGB(
                                            255,
                                            44,
                                            8,
                                            204,
                                          )
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
                                  icon: const Icon(Icons.volume_up),
                                  iconSize: 40,
                                  color:
                                      _isPressingFull
                                          ? const Color.fromARGB(
                                            255,
                                            44,
                                            8,
                                            204,
                                          )
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
