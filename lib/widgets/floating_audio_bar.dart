import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/audio_player_provider.dart';

class FloatingAudioBar extends ConsumerWidget {
  const FloatingAudioBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioNotifier = ref.read(audioPlayerProvider.notifier);

    if (!audioState.hasActiveAudio) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail / Wave Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: audioState.imageUrl != null && audioState.imageUrl!.isNotEmpty
                  ? Image.network(
                      audioState.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.graphic_eq,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.graphic_eq,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Title & Status
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audioState.title ?? 'Đang phát âm thanh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: audioState.isPlaying ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      audioState.isPlaying
                          ? (audioState.isBrief ? 'Đang đọc tóm tắt AI' : 'Đang đọc toàn văn')
                          : 'Đang tạm dừng',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Speed Button
          InkWell(
            onTap: () => audioNotifier.cycleSpeed(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                audioState.speedLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Play/Pause Button
          IconButton(
            onPressed: () => audioNotifier.togglePlayPause(),
            icon: Icon(
              audioState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),

          // Close/Stop Button
          IconButton(
            onPressed: () => audioNotifier.stop(),
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white54 : Colors.black45,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
