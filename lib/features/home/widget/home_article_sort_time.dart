import 'package:flutter/material.dart';

class HomeArticleSortTime extends StatefulWidget {
  const HomeArticleSortTime({super.key});

  @override
  _HomeArticleSortTimeState createState() => _HomeArticleSortTimeState();
}

class _HomeArticleSortTimeState extends State<HomeArticleSortTime> {
  String _sortTimeValue = getSortTimeValue()[0];

  void onSortOptionChanged(String? newValue) {
    // Tìm giá trị value tương ứng với label được chọn
    String? correspondingValue = getSortTimeValue().firstWhere(
      (value) => getSortTimeLabel(value) == newValue,
      orElse: () => getSortTimeValue()[0],
    );

    setState(() {
      _sortTimeValue = correspondingValue;
    });
    print('Selected sort option: $newValue (value: $correspondingValue)');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: getSortTimeLabel(_sortTimeValue),
          items:
              getSortTimeValue().map((String value) {
                return DropdownMenuItem<String>(
                  value: getSortTimeLabel(
                    value,
                  ), // Sử dụng label làm value cho item
                  child: Text(getSortTimeLabel(value)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            onSortOptionChanged(newValue);
          },
        ),
      ),
    );
  }
}

// Hàm getSortTimeValue() để định nghĩa const cho value
// Bộ lọc theo ngày: Mọi thời gian, hôm nay, 3 ngày trước, 7 ngày trước
List<String> getSortTimeValue() {
  return ['AllTime', 'Today', '3DaysAgo', '7DaysAgo'];
}

String getSortTimeLabel(String value) {
  switch (value) {
    case 'AllTime':
      return 'All Time';
    case 'Today':
      return 'Today';
    case '3DaysAgo':
      return '3 Days Ago';
    case '7DaysAgo':
      return '7 Days Ago';
    default:
      return 'Unknown';
  }
}
