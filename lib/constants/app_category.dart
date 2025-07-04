import 'package:assignment_3_safe_news/features/home/model/category_model.dart';

/// App Category constants and utilities
/// Contains all news categories used throughout the application
// cspell:disable
class AppCategory {
  AppCategory._(); // Private constructor to prevent instantiation

  // Category constants
  static const String tinMoiNhat = 'tin-moi-nhat';
  static const String tinXemNhieu = 'tin-xem-nhieu';
  static const String theGioi = 'the-gioi';
  static const String thoiSu = 'thoi-su';
  static const String kinhDoanh = 'kinh-doanh';
  static const String startup = 'startup';
  static const String giaiTri = 'giai-tri';
  static const String theThao = 'the-thao';
  static const String phapLuat = 'phap-luat';
  static const String giaoDuc = 'giao-duc';
  static const String sucKhoe = 'suc-khoe';
  static const String giaDinh = 'gia-dinh';
  static const String duLich = 'du-lich';
  static const String khoaHocCongNghe = 'khoa-hoc-cong-nghe';
  static const String otoXeMay = 'oto-xe-may';
  static const String yKien = 'y-kien';
  static const String tamSu = 'tam-su';
  static const String cuoi = 'cuoi';
}

/// Map of all available categories with their display names and slugs
const Map<String, CategoryModel> categories = {
  AppCategory.tinMoiNhat: CategoryModel(
    name: 'Tin mới nhất',
    slug: AppCategory.tinMoiNhat,
  ),
  AppCategory.tinXemNhieu: CategoryModel(
    name: 'Tin xem nhiều',
    slug: AppCategory.tinXemNhieu,
  ),
  AppCategory.theGioi: CategoryModel(
    name: 'Thế giới',
    slug: AppCategory.theGioi,
  ),
  AppCategory.thoiSu: CategoryModel(name: 'Thời sự', slug: AppCategory.thoiSu),
  AppCategory.kinhDoanh: CategoryModel(
    name: 'Kinh doanh',
    slug: AppCategory.kinhDoanh,
  ),
  AppCategory.startup: CategoryModel(
    name: 'Startup',
    slug: AppCategory.startup,
  ),
  AppCategory.giaiTri: CategoryModel(
    name: 'Giải trí',
    slug: AppCategory.giaiTri,
  ),
  AppCategory.theThao: CategoryModel(
    name: 'Thể thao',
    slug: AppCategory.theThao,
  ),
  AppCategory.phapLuat: CategoryModel(
    name: 'Pháp luật',
    slug: AppCategory.phapLuat,
  ),
  AppCategory.giaoDuc: CategoryModel(
    name: 'Giáo dục',
    slug: AppCategory.giaoDuc,
  ),
  AppCategory.sucKhoe: CategoryModel(
    name: 'Sức khỏe',
    slug: AppCategory.sucKhoe,
  ),
  AppCategory.giaDinh: CategoryModel(
    name: 'Gia đình',
    slug: AppCategory.giaDinh,
  ),
  AppCategory.duLich: CategoryModel(name: 'Du lịch', slug: AppCategory.duLich),
  AppCategory.khoaHocCongNghe: CategoryModel(
    name: 'Khoa học công nghệ',
    slug: AppCategory.khoaHocCongNghe,
  ),
  AppCategory.otoXeMay: CategoryModel(
    name: 'Ô tô xe máy',
    slug: AppCategory.otoXeMay,
  ),
  AppCategory.yKien: CategoryModel(name: 'Ý kiến', slug: AppCategory.yKien),
  AppCategory.tamSu: CategoryModel(name: 'Tâm sự', slug: AppCategory.tamSu),
  AppCategory.cuoi: CategoryModel(name: 'Cười', slug: AppCategory.cuoi),
};

/// Gets the display name from category slug
/// Returns empty string if category not found
String getNameFromCategory(String slug) {
  return categories[slug]?.name ?? '';
}

/// Gets the slug from category display name
/// Returns empty string if category not found
String getSlugFromName(String name) {
  for (final entry in categories.entries) {
    if (entry.value.name.toLowerCase() == name.toLowerCase()) {
      return entry.key;
    }
  }
  return '';
}
