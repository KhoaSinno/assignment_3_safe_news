import 'package:flutter/material.dart';

class AppCategory {
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

List<Map<String, String>> Categories = [
  {'name': 'Tin mới nhất', 'slug': AppCategory.tinMoiNhat},
  {'name': 'Tin xem nhiều', 'slug': AppCategory.tinXemNhieu},
  {'name': 'Thế giới', 'slug': AppCategory.theGioi},
  {'name': 'Thời sự', 'slug': AppCategory.thoiSu},
  {'name': 'Kinh doanh', 'slug': AppCategory.kinhDoanh},
  {'name': 'Startup', 'slug': AppCategory.startup},
  {'name': 'Giải trí', 'slug': AppCategory.giaiTri},
  {'name': 'Thể thao', 'slug': AppCategory.theThao},
  {'name': 'Pháp luật', 'slug': AppCategory.phapLuat},
  {'name': 'Giáo dục', 'slug': AppCategory.giaoDuc},
  {'name': 'Sức khỏe', 'slug': AppCategory.sucKhoe},
  {'name': 'Gia đình', 'slug': AppCategory.giaDinh},
  {'name': 'Du lịch', 'slug': AppCategory.duLich},
  {'name': 'Khoa học công nghệ', 'slug': AppCategory.khoaHocCongNghe},
  {'name': 'Ô tô xe máy', 'slug': AppCategory.otoXeMay},
  {'name': 'Ý kiến', 'slug': AppCategory.yKien},
  {'name': 'Tâm sự', 'slug': AppCategory.tamSu},
  {'name': 'Cười', 'slug': AppCategory.cuoi},
];

// Hàm ánh xạ từ slug sang tên danh mục
String getNameFromCategory(String slug) {
  switch (slug) {
    case AppCategory.tinMoiNhat:
      return 'Tin mới nhất';
    case AppCategory.tinXemNhieu:
      return 'Tin xem nhiều';
    case AppCategory.theGioi:
      return 'Thế giới';
    case AppCategory.thoiSu:
      return 'Thời sự';
    case AppCategory.kinhDoanh:
      return 'Kinh doanh';
    case AppCategory.startup:
      return 'Startup';
    case AppCategory.giaiTri:
      return 'Giải trí';
    case AppCategory.theThao:
      return 'Thể thao';
    case AppCategory.phapLuat:
      return 'Pháp luật';
    case AppCategory.giaoDuc:
      return 'Giáo dục';
    case AppCategory.sucKhoe:
      return 'Sức khỏe';
    case AppCategory.giaDinh:
      return 'Gia đình';
    case AppCategory.duLich:
      return 'Du lịch';
    case AppCategory.khoaHocCongNghe:
      return 'Khoa học công nghệ';
    case AppCategory.otoXeMay:
      return 'Ô tô xe máy';
    case AppCategory.yKien:
      return 'Ý kiến';
    case AppCategory.tamSu:
      return 'Tâm sự';
    case AppCategory.cuoi:
      return 'Cười';
    default:
      return '';
  }
}

// Hàm ánh xạ tên danh mục
String getCategoryFromName(String name) {
  switch (name.toLowerCase()) {
    case AppCategory.tinMoiNhat:
      return AppCategory.tinMoiNhat;
    case AppCategory.tinXemNhieu:
      return AppCategory.tinXemNhieu;
    case AppCategory.theGioi:
      return AppCategory.theGioi;
    case AppCategory.thoiSu:
      return AppCategory.thoiSu;
    case AppCategory.kinhDoanh:
      return AppCategory.kinhDoanh;
    case AppCategory.startup:
      return AppCategory.startup;
    case AppCategory.giaiTri:
      return AppCategory.giaiTri;
    case AppCategory.theThao:
      return AppCategory.theThao;
    case AppCategory.phapLuat:
      return AppCategory.phapLuat;
    case AppCategory.giaoDuc:
      return AppCategory.giaoDuc;
    case AppCategory.sucKhoe:
      return AppCategory.sucKhoe;
    case AppCategory.giaDinh:
      return AppCategory.giaDinh;
    case AppCategory.duLich:
      return AppCategory.duLich;
    case AppCategory.khoaHocCongNghe:
      return AppCategory.khoaHocCongNghe;
    case AppCategory.otoXeMay:
      return AppCategory.otoXeMay;
    case AppCategory.yKien:
      return AppCategory.yKien;
    case AppCategory.tamSu:
      return AppCategory.tamSu;
    case AppCategory.cuoi:
      return AppCategory.cuoi;
    default:
      return '';
  }
}

Widget buildCategoryChip(String label, {bool isSelected = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isSelected ? Colors.black : const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(8),
      border:
          isSelected
              ? null
              : Border.all(color: const Color(0xFFCAABB4), width: 1),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontSize: 12,
        fontFamily: 'Aleo',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
