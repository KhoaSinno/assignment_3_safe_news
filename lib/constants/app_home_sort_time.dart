List<String> getSortTimeValue() {
  return ['AllTime', 'Today', '3DaysAgo', '7DaysAgo'];
}

String getSortTimeLabel(String value) {
  switch (value) {
    case 'AllTime':
      return 'Mọi Thời Điểm';
    case 'Today':
      return 'Hôm Nay';
    case '3DaysAgo':
      return '3 Ngày Trước';
    case '7DaysAgo':
      return '7 Ngày Trước';
    default:
      return 'Chưa Xác Định';
  }
}
