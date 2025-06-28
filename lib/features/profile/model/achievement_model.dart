import 'package:flutter/material.dart';

enum Achievement {
  newbie, // "Người mới" - Mặc định khi đăng nhập (priority: 1)
  firstRead, // "Khởi đầu" - Đọc bài đầu tiên (priority: 2)
  dailyReader, // "Hàng ngày" - Đọc 5 bài trong ngày (priority: 3)
  explorer, // "Khám phá" - Đọc 3 category khác nhau (priority: 4)
  weekStreak, // "Tuần lễ" - Đọc 7 ngày liên tục (priority: 5)
  bookworm, // "Mọt sách" - Đọc 50 bài tổng cộng (priority: 6)
}

extension AchievementModel on Achievement {
  String get title {
    switch (this) {
      case Achievement.newbie:
        return 'Mới bắt đầu cày cuốc';
      case Achievement.firstRead:
        return 'Khởi đầu gọn lẹ';
      case Achievement.dailyReader:
        return 'Hàng ngày';
      case Achievement.explorer:
        return 'Khám phá';
      case Achievement.weekStreak:
        return 'Tuần lễ';
      case Achievement.bookworm:
        return 'Mọt sách';
    }
  }

  // SVG asset path
  String get assetPath {
    switch (this) {
      case Achievement.newbie:
        return 'assets/achievements/newbie.svg';
      case Achievement.firstRead:
        return 'assets/achievements/first_read.svg';
      case Achievement.dailyReader:
        return 'assets/achievements/daily_reader.svg';
      case Achievement.explorer:
        return 'assets/achievements/explorer.svg';
      case Achievement.weekStreak:
        return 'assets/achievements/week_streak.svg';
      case Achievement.bookworm:
        return 'assets/achievements/bookworm.svg';
    }
  }

  // Icon fallback khi không có SVG
  IconData get icon {
    switch (this) {
      case Achievement.newbie:
        return Icons.person;
      case Achievement.firstRead:
        return Icons.article;
      case Achievement.dailyReader:
        return Icons.today;
      case Achievement.explorer:
        return Icons.explore;
      case Achievement.weekStreak:
        return Icons.local_fire_department;
      case Achievement.bookworm:
        return Icons.menu_book;
    }
  }

  // Color cho achievement avatar
  Color get color {
    switch (this) {
      case Achievement.newbie:
        return const Color(0xFF9E9E9E); // Gray
      case Achievement.firstRead:
        return const Color(0xFF4CAF50); // Green
      case Achievement.dailyReader:
        return const Color(0xFF2196F3); // Blue
      case Achievement.explorer:
        return const Color(0xFF9C27B0); // Purple
      case Achievement.weekStreak:
        return const Color(0xFFFF5722); // Deep Orange
      case Achievement.bookworm:
        return const Color(0xFFFF9800); // Orange
    }
  }

  // Priority cho việc hiển thị (cao nhất sẽ làm profile avatar)
  int get priority {
    switch (this) {
      case Achievement.bookworm:
        return 6; // Cao nhất
      case Achievement.weekStreak:
        return 5;
      case Achievement.explorer:
        return 4;
      case Achievement.dailyReader:
        return 3;
      case Achievement.firstRead:
        return 2;
      case Achievement.newbie:
        return 1; // Thấp nhất (mặc định)
    }
  }
}
