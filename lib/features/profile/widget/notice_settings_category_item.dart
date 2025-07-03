import 'package:flutter/material.dart';

class NoticeSettingsCategoryItem extends StatelessWidget {
  NoticeSettingsCategoryItem({
    super.key,
    required this.category,
    required this.isSubscribed,
    required this.onChanged,
  });
  final String category;
  final bool isSubscribed;
  final Function(bool) onChanged;

  final categoryNames = {
    'breaking_news': 'Tin nóng',
    'sports': 'Thể thao',
    'technology': 'Công nghệ',
    'business': 'Kinh doanh',
    'entertainment': 'Giải trí',
    'health': 'Sức khỏe',
    'science': 'Khoa học',
  };

  final categoryIcons = {
    'breaking_news': Icons.warning,
    'sports': Icons.sports_soccer,
    'technology': Icons.computer,
    'business': Icons.business,
    'entertainment': Icons.movie,
    'health': Icons.health_and_safety,
    'science': Icons.science,
  };
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        categoryIcons[category] ?? Icons.article,
        color: isSubscribed ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(categoryNames[category] ?? category),
      trailing: Switch(
        value: isSubscribed,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
      ),
      onTap: () => onChanged(!isSubscribed),
    );
  }
}
