import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Hàm phân tích ngày an toàn tuyệt đối từ Firestore/RSS
/// Hỗ trợ tất cả các định dạng ngày từ VnExpress, Tuổi Trẻ, Dân Trí, ISO 8601, Timestamp...
DateTime parseSafePublishedDate(dynamic rawValue) {
  if (rawValue == null) {
    return DateTime.now();
  }

  // 1. Trường hợp đã là DateTime
  if (rawValue is DateTime) {
    return rawValue;
  }

  // 2. Trường hợp là Firestore Timestamp
  if (rawValue is Timestamp) {
    return rawValue.toDate();
  }

  // 3. Trường hợp là epoch milliseconds
  if (rawValue is int) {
    return DateTime.fromMillisecondsSinceEpoch(rawValue);
  }

  if (rawValue is! String) {
    return DateTime.now();
  }

  final dateStr = rawValue.trim();
  if (dateStr.isEmpty) {
    return DateTime.now();
  }

  // 4. Thử parse theo chuẩn ISO 8601 (2026-08-29T09:20:00Z, 2026-08-29 09:20:00...)
  final isoParsed = DateTime.tryParse(dateStr);
  if (isoParsed != null) {
    return isoParsed;
  }

  // 5. Thử các định dạng RSS và ngày giờ thực tế từ các đầu báo
  final formatPatterns = [
    // Định dạng RFC-822 (VnExpress, Tuổi Trẻ): "Fri, 28 Aug 2026 14:00:00 +0700"
    'EEE, dd MMM yyyy HH:mm:ss Z',
    'EEE, d MMM yyyy HH:mm:ss Z',
    'EEE, dd MMM yyyy HH:mm:ss',
    'EEE, d MMM yyyy HH:mm:ss',
    
    // Định dạng US/Dân Trí: "8/29/2026 9:20:00 AM", "08/29/2026 09:20:00 PM"
    'M/d/yyyy h:mm:ss a',
    'M/d/yyyy hh:mm:ss a',
    'M/d/yyyy h:mm a',
    'M/d/yyyy hh:mm a',
    'M/d/yyyy H:mm:ss',
    'M/d/yyyy HH:mm:ss',
    'M/d/yyyy H:mm',
    'M/d/yyyy HH:mm',

    // Định dạng Việt Nam: "29/08/2026 09:20:00", "29/08/2026 09:20"
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy HH:mm',
    'd/M/yyyy HH:mm:ss',
    'd/M/yyyy HH:mm',
    'dd-MM-yyyy HH:mm:ss',
    'dd-MM-yyyy HH:mm',

    // Định dạng chuẩn: "2026-08-29 HH:mm:ss", "2026/08/29 HH:mm:ss"
    'yyyy-MM-dd HH:mm:ss',
    'yyyy/MM/dd HH:mm:ss',
    'yyyy-MM-dd HH:mm',
    'yyyy/MM/dd HH:mm',
  ];

  for (final pattern in formatPatterns) {
    try {
      return DateFormat(pattern, 'en_US').parse(dateStr);
    } catch (_) {
      try {
        return DateFormat(pattern).parse(dateStr);
      } catch (_) {}
    }
  }

  // 6. Fallback an toàn: Trả về DateTime.now() thay vì quăng Exception làm crash UI
  return DateTime.now();
}
