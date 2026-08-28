import 'package:assignment_3_safe_news/features/home/viewmodel/article_item_viewmodel.dart';
import 'package:assignment_3_safe_news/providers/search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeArticleSearch extends ConsumerStatefulWidget {
  const HomeArticleSearch({super.key});

  @override
  ConsumerState<HomeArticleSearch> createState() => _HomeArticleSearchState();
}

class _HomeArticleSearchState extends ConsumerState<HomeArticleSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSentiment = ref.watch(sentimentFilterProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardTheme.color
                      : Theme.of(context).appBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tin tức an toàn...',
                      hintStyle: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        fontSize: 15,
                        fontFamily: 'Aleo',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      ref
                          .read(debouncedSearchProvider.notifier)
                          .updateSearchQuery(value);
                    },
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {});
                      ref
                          .read(debouncedSearchProvider.notifier)
                          .updateSearchQuery('');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Sentiment Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSentimentChip(
                  context: context,
                  label: '🌟 Tất cả',
                  isSelected: currentSentiment == null,
                  onTap: () {
                    ref.read(sentimentFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context: context,
                  label: '🌿 Tin Tích Cực',
                  isSelected: currentSentiment == 1,
                  activeColor: const Color(0xFF2E7D32),
                  activeBgColor: const Color(0xFFE8F5E9),
                  onTap: () {
                    ref.read(sentimentFilterProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(width: 8),
                _buildSentimentChip(
                  context: context,
                  label: '🛡️ Cảnh Báo An Toàn',
                  isSelected: currentSentiment == 0,
                  activeColor: const Color(0xFF1565C0),
                  activeBgColor: const Color(0xFFE3F2FD),
                  onTap: () {
                    ref.read(sentimentFilterProvider.notifier).state = 0;
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentimentChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
    Color? activeBgColor,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (activeBgColor ?? (isDark ? primary.withValues(alpha: 0.3) : primary.withValues(alpha: 0.12)))
              : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (activeColor ?? primary)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (activeColor ?? (isDark ? Colors.white : primary))
                : (isDark ? Colors.white70 : Colors.black54),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
