import 'package:assignment_3_safe_news/constants/app_home_sort_time.dart';
import 'package:flutter/material.dart';

class HomeArticleSortTime extends StatefulWidget {
  const HomeArticleSortTime({super.key});

  @override
  HomeArticleSortTimeState createState() => HomeArticleSortTimeState();
}

class HomeArticleSortTimeState extends State<HomeArticleSortTime> {
  String _sortTimeValue = getSortTimeValue()[0];

  void onSortOptionChanged(String? newValue) {
    setState(() {
      _sortTimeValue = newValue ?? getSortTimeValue()[0];
    });
    print('Selected sort option (value: $_sortTimeValue)');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: DropdownButton<String>(
          isExpanded: true,
          value: _sortTimeValue,
          items:
              getSortTimeValue().map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
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
