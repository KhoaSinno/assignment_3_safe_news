import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:assignment_3_safe_news/features/home/ui/detail_article.dart';
import 'package:assignment_3_safe_news/features/home/repository/article_item_repository.dart';
import 'package:assignment_3_safe_news/utils/tts_service.dart';
import 'package:assignment_3_safe_news/utils/article_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ArticleItem extends StatefulWidget {
  const ArticleItem({super.key, required this.article});
  final dynamic article;

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  final TTSService _ttsService = TTSService();
  bool _isLoadingSummary = false;
  String? _cachedSummary;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
  }

  Future<void> _speakArticleSummary() async {
    // Nếu đang đọc summary này, thì dừng
    String summaryText = _cachedSummary ?? widget.article.description;
    if (_ttsService.isSpeaking(summaryText)) {
      await _ttsService.stop();
      return;
    }

    // Nếu chưa có summary cached, thì tạo mới
    if (_cachedSummary == null) {
      setState(() {
        _isLoadingSummary = true;
      });

      try {
        // Fetch content và tạo summary
        String content = await ArticleItemRepository.getContentWithCache(
          widget.article.link,
        );
        String plainText = extractTextFromHtml(content);

        if (plainText.isNotEmpty) {
          _cachedSummary = await ArticleItemRepository.summaryContentGemini(
            plainText,
          );
        } else {
          _cachedSummary = widget.article.description;
        }

        setState(() {
          _isLoadingSummary = false;
        });

        // Speak summary sau khi load xong
        await _ttsService.speak(_cachedSummary!);
      } catch (e) {
        setState(() {
          _isLoadingSummary = false;
          _cachedSummary = widget.article.description;
        });
        await _ttsService.speak(_cachedSummary!);
      }
    } else {
      // Đã có cache, speak ngay
      await _ttsService.speak(_cachedSummary!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailArticle(article: widget.article),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.article.imageUrl),
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
                  widget.article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headlineMedium?.color,
                    fontSize: 18,
                    fontFamily: 'Aleo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      getNameFromCategory(widget.article.category),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                        fontFamily: 'Merriweather',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          _isLoadingSummary ? null : _speakArticleSummary,
                      icon:
                          _isLoadingSummary
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Icon(
                                Icons.volume_up,
                                color:
                                    _ttsService.isSpeaking(
                                          _cachedSummary ??
                                              widget.article.description,
                                        )
                                        ? const Color.fromARGB(255, 44, 8, 204)
                                        : Theme.of(context).iconTheme.color
                                            ?.withValues(alpha: 0.54),
                              ),
                      iconSize: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(widget.article.published).toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        try {
                          final String shareText =
                              widget.article.link != null &&
                                      widget.article.link.isNotEmpty
                                  ? 'Check out this article: ${widget.article.title}\n\n${widget.article.link}'
                                  : 'Check out this article: ${widget.article.title}';

                          await Share.share(shareText);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Chia sẻ thành công!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          final String shareText =
                              widget.article.link != null &&
                                      widget.article.link.isNotEmpty
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
                      },
                      icon: Icon(
                        Icons.share_outlined,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
