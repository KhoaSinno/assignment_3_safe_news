// cspell:disable
import 'dart:async';
// APP
import 'package:assignment_3_safe_news/features/authentication/ui/login_screen.dart';
import 'package:assignment_3_safe_news/features/bookmark/model/bookmark_model.dart';
import 'package:assignment_3_safe_news/features/bookmark/viewmodel/bookmark_item_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:assignment_3_safe_news/providers/user_stats_provider.dart';
import 'package:assignment_3_safe_news/providers/font_size_provider.dart';
import 'package:assignment_3_safe_news/providers/audio_player_provider.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/utils/index.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// PACKAGES
import 'package:flutter/material.dart';
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

  // Tracking user reading article
  Timer? _readingTimer;
  int _seconds = 0;
  bool _hasTracking = false;
  @override
  void initState() {
    super.initState();
    // Khởi tạo tóm tắt tức thì từ description đã được AI xử lý từ trước (0s latency)
    _summary = widget.article.description.isNotEmpty
        ? widget.article.description
        : null;
    _isLoadingSummary = _summary == null;
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
        // Chỉ gọi Gemini nếu bài báo chưa có description
        if (_summary == null || _summary!.isEmpty) {
          final summary = await ArticleItemRepository.summaryContentGemini(
            plainTextContent,
          );
          if (mounted) {
            setState(() {
              _summary = summary;
              _isLoadingSummary = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_isLoadingArticle) {
            _articleHtmlContent = '<p>Lỗi khi tải nội dung: $e</p>';
          }
          if (_summary == null || _summary!.isEmpty) {
            _summary = widget.article.description.isNotEmpty
                ? widget.article.description
                : 'Không thể tạo bản tóm tắt lúc này.';
          }
          _isLoadingArticle = false;
          _isLoadingSummary = false;
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

  void _showFontSizeBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentOption = ref.watch(fontSizeProvider);
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.format_size, color: Color(0xFF9F224E)),
                      SizedBox(width: 8),
                      Text(
                        'Tùy chỉnh cỡ chữ đọc bài',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...FontSizeOption.values.map((opt) {
                    final isSelected = opt == currentOption;
                    return ListTile(
                      title: Text(
                        opt.label,
                        style: TextStyle(
                          fontSize: 15 * opt.scale,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF9F224E) : null,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF9F224E))
                          : null,
                      onTap: () {
                        ref.read(fontSizeProvider.notifier).setOption(opt);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReportDialog() {
    final reasons = [
      'Nội dung tiêu cực / bạo lực chưa được lọc',
      'Thông tin sai sự thật / Giả mạo',
      'Tóm tắt AI chưa chính xác',
      'Nội dung giật gân, phản cảm',
    ];
    String selectedReason = reasons[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.report_problem_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Báo cáo bài viết', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Giúp chúng tôi cải thiện bộ lọc AI bằng cách chọn lý do:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...reasons.map((r) => RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(r, style: const TextStyle(fontSize: 13)),
                        value: r,
                        groupValue: selectedReason,
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedReason = val);
                          }
                        },
                      )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9F224E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _submitReport(selectedReason);
                  },
                  child: const Text('Gửi báo cáo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String reason) async {
    try {
      await FirebaseFirestore.instance.collection('article_reports').add({
        'article_id': widget.article.id,
        'title': widget.article.title,
        'link': widget.article.link,
        'reason': reason,
        'reported_at': FieldValue.serverTimestamp(),
        'user_id': FirebaseAuth.instance.currentUser?.uid ?? 'anonymous',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn! Báo cáo đã được ghi nhận để cải tiến AI.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi báo cáo: $e'), backgroundColor: Colors.red),
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
            tooltip: 'Cỡ chữ',
            icon: Icon(Icons.format_size, color: Theme.of(context).iconTheme.color),
            onPressed: _showFontSizeBottomSheet,
          ),
          IconButton(
            tooltip: 'Báo cáo bài viết',
            icon: Icon(Icons.outlined_flag, color: Theme.of(context).iconTheme.color),
            onPressed: _showReportDialog,
          ),
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
                  // Sentiment Safety Badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.article.sentiment == 1
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.article.sentiment == 1
                            ? const Color(0xFF81C784)
                            : const Color(0xFF90CAF9),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.article.sentiment == 1 ? Icons.eco : Icons.verified_user,
                          size: 16,
                          color: widget.article.sentiment == 1
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.article.sentiment == 1 ? 'Tin Tích Cực' : 'Tin Cảnh Báo An Toàn',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.article.sentiment == 1
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF1565C0),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  // Summary Section
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
                            : Consumer(
                                builder: (context, ref, child) {
                                  final audioState = ref.watch(audioPlayerProvider);
                                  final isSpeakingSummary = audioState.articleId ==
                                          widget.article.id &&
                                      audioState.isPlaying &&
                                      audioState.isBrief;

                                  return IconButton(
                                    onPressed: () {
                                      final textToSpeak = _summary ??
                                          (widget.article.description.isNotEmpty
                                              ? widget.article.description
                                              : widget.article.title);
                                      ref.read(audioPlayerProvider.notifier).playArticle(
                                            id: widget.article.id,
                                            title: widget.article.title,
                                            text: textToSpeak,
                                            imageUrl: widget.article.imageUrl,
                                          );
                                    },
                                    icon: Icon(
                                      isSpeakingSummary ? Icons.volume_up : Icons.volume_up_outlined,
                                    ),
                                    iconSize: 36,
                                    color: isSpeakingSummary
                                        ? const Color(0xFF9F224E)
                                        : Theme.of(context)
                                            .iconTheme
                                            .color
                                            ?.withValues(alpha: 0.54),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingSummary
                      ? const Center(child: CircularProgressIndicator())
                      : Consumer(
                          builder: (context, ref, child) {
                            final fontScale = ref.watch(fontSizeProvider).scale;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                _summary ?? 'Đang tải tóm tắt...',
                                textAlign: TextAlign.justify,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 16 * fontScale,
                                      fontFamily: 'Merriweather',
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 24),

                  // Full Article Section
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
                            : Consumer(
                                builder: (context, ref, child) {
                                  final audioState = ref.watch(audioPlayerProvider);
                                  final isSpeakingFull = audioState.articleId ==
                                          widget.article.id &&
                                      audioState.isPlaying &&
                                      !audioState.isBrief;

                                  return IconButton(
                                    onPressed: () {
                                      final textToSpeak = _plainTextContent.isNotEmpty
                                          ? _plainTextContent
                                          : (_summary ?? widget.article.description);
                                      ref.read(audioPlayerProvider.notifier).playArticle(
                                            id: widget.article.id,
                                            title: widget.article.title,
                                            text: textToSpeak,
                                            imageUrl: widget.article.imageUrl,
                                            isBrief: false,
                                          );
                                    },
                                    icon: Icon(
                                      isSpeakingFull ? Icons.volume_up : Icons.volume_up_outlined,
                                    ),
                                    iconSize: 36,
                                    color: isSpeakingFull
                                        ? const Color(0xFF9F224E)
                                        : Theme.of(context)
                                            .iconTheme
                                            .color
                                            ?.withValues(alpha: 0.54),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingArticle
                      ? const Center(child: CircularProgressIndicator())
                      : Consumer(
                          builder: (context, ref, child) {
                            final fontScale = ref.watch(fontSizeProvider).scale;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: HtmlWidget(
                                _articleHtmlContent ?? '<p>Không có nội dung.</p>',
                                textStyle: TextStyle(
                                  fontSize: 16 * fontScale,
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
                                  if (element.localName == 'img') {
                                    return {
                                      'display': 'block',
                                      'max-width': '100%',
                                      'height': 'auto',
                                      'margin': '16px auto',
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
                            );
                          },
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
