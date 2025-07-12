import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AchievementToastService {
  static void showAchievementUnlocked(
    BuildContext context,
    Achievement achievement,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => AchievementToast(
            achievement: achievement,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class AchievementToast extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementToast({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<AchievementToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 100),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: screenWidth - 32,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.achievement.color.withOpacity(0.9),
                        widget.achievement.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Achievement Icon/Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          widget.achievement.assetPath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              widget.achievement.icon,
                              color: Colors.white,
                              size: 32,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Achievement Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎉 Thành tựu mới!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.achievement.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getAchievementDescription(widget.achievement),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getAchievementDescription(Achievement achievement) {
    switch (achievement) {
      case Achievement.newbie:
        return 'Chào mừng bạn đến với SafeNews!';
      case Achievement.firstRead:
        return 'Bạn đã đọc bài báo đầu tiên!';
      case Achievement.dailyReader:
        return 'Đọc 5 bài trong ngày!';
      case Achievement.explorer:
        return 'Khám phá 3 danh mục khác nhau!';
      case Achievement.weekStreak:
        return 'Đọc báo 7 ngày liên tiếp!';
      case Achievement.bookworm:
        return 'Đã đọc 50 bài báo!';
    }
  }
}
