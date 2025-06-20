import 'package:assignment_3_safe_news/constants/app_category.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => AppCategory.tinMoiNhat);

// final textSearchProvider = StateProvider<String?>((ref) => null);