  // Hàm lấy thứ trong tuần bằng tiếng Việt
  String getVietnameseDayOfWeek(DateTime date) {
    const List<String> daysInVietnamese = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    return daysInVietnamese[date.weekday - 1];
  }

