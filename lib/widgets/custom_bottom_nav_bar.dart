import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:assignment_3_safe_news/providers/bottom_nav_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isDarkMode
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_rounded,
                  index: 0,
                  currentIndex: currentIndex,
                  isDarkMode: isDarkMode,
                  onTap:
                      () => ref.read(bottomNavIndexProvider.notifier).state = 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.bookmark_rounded,
                  index: 1,
                  currentIndex: currentIndex,
                  isDarkMode: isDarkMode,
                  onTap:
                      () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_rounded,
                  index: 2,
                  currentIndex: currentIndex,
                  isDarkMode: isDarkMode,
                  onTap:
                      () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required int index,
    required int currentIndex,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDarkMode
                            ? const Color.fromARGB(181, 159, 34, 78)
                            : const Color(0xFF9F224E))
                        .withValues(alpha: 0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 24,
            color:
                isSelected
                    ? (isDarkMode
                        ? const Color.fromARGB(181, 159, 34, 78)
                        : const Color(0xFF9F224E))
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
