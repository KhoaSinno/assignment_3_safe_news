import 'package:assignment_3_safe_news/constants/app_category.dart';
import 'package:assignment_3_safe_news/features/home/ui/detail_article.dart';
import 'package:assignment_3_safe_news/providers/audio_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:assignment_3_safe_news/utils/index.dart';

class ArticleItem extends ConsumerStatefulWidget {
  const ArticleItem({super.key, required this.article});
  final dynamic article;

  @override
  ConsumerState<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends ConsumerState<ArticleItem> {
  Future<void> _speakArticleSummary() async {
    final String summaryText = (widget.article.description != null &&
            widget.article.description.isNotEmpty)
        ? widget.article.description
        : widget.article.title;

    final audioNotifier = ref.read(audioPlayerProvider.notifier);
    await audioNotifier.playArticle(
      id: widget.article.id ?? widget.article.title,
      title: widget.article.title,
      text: summaryText,
      imageUrl: widget.article.imageUrl,
    );
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
                image: getImageProvider(widget),
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
                    // Category Name
                    Text(
                      getNameFromCategory(widget.article.category),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 13,
                        fontFamily: 'Merriweather',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mini Sentiment Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.article.sentiment == 1
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.article.sentiment == 1 ? '🌿 Tích cực' : '🛡️ An toàn',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.article.sentiment == 1
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _speakArticleSummary,
                      icon: Builder(
                        builder: (context) {
                          final audioState = ref.watch(audioPlayerProvider);
                          final isSpeaking = audioState.articleId == (widget.article.id ?? widget.article.title) && audioState.isPlaying;
                          return Icon(
                            isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                            color: isSpeaking
                                ? const Color(0xFF9F224E)
                                : Theme.of(context)
                                    .iconTheme
                                    .color
                                    ?.withValues(alpha: 0.54),
                          );
                        },
                      ),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          final String shareText =
                              widget.article.link != null &&
                                      widget.article.link.isNotEmpty
                                  ? 'Check out this article: ${widget.article.title}\n\n${widget.article.link}'
                                  : 'Check out this article: ${widget.article.title}';

                          await SharePlus.instance.share(
                            ShareParams(text: shareText),
                          );

                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Chia sẻ thành công!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } catch (e) {
                          // Silently handle error or log it
                          // showDialog removed to avoid async context issues
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
