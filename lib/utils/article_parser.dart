import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:io';

Future<String> fetchArticleContent({required String? url}) async {
  if (url == null || url.isEmpty) {
    return '<p>Đường dẫn bài viết không hợp lệ.</p>';
  }

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      // Attempt to find the main content element. This selector might need adjustment
      // based on the common structures of the websites you're targeting.
      dom.Element? contentElement = document.querySelector(
        '.fck_detail',
      ); // Common for VnExpress
      contentElement ??= document.querySelector('article');
      contentElement ??= document.querySelector('.content');
      contentElement ??= document.querySelector('.main-content');
      contentElement ??= document.querySelector('#content');
      // Add more selectors if needed or use a more generic approach

      final String htmlContent =
          contentElement?.outerHtml ??
          document.body?.innerHtml ??
          '<p>Không tìm thấy nội dung chi tiết.</p>';

      // Pre-process HTML to handle data-src for images
      final doc = parser.parse(htmlContent);

      // Fix images
      doc.querySelectorAll('img').forEach((imgElement) {
        final dataSrc = imgElement.attributes['data-src'];
        final src = imgElement.attributes['src'];
        if (dataSrc != null && dataSrc.isNotEmpty) {
          if (src == null ||
              src.isEmpty ||
              src.startsWith('data:image/gif;base64')) {
            // Common placeholder pattern
            imgElement.attributes['src'] = dataSrc;
          }
        }
        // Remove lazy loading attributes that might prevent immediate display
        imgElement.attributes.remove('loading');
        // Remove problematic inline styles that cause text wrapping issues
        imgElement.attributes.remove('style');
        imgElement.attributes.remove('align');
        imgElement.attributes.remove('width');
        imgElement.attributes.remove('height');
      });

      // Clean up table elements that often cause layout issues
      doc.querySelectorAll('table').forEach((table) {
        table.attributes.remove('style');
        table.attributes.remove('width');
      });

      // Clean up figure/picture elements
      doc.querySelectorAll('figure, picture').forEach((element) {
        element.attributes.remove('style');
      });

      // Clean up paragraph and div styles that cause layout issues
      doc.querySelectorAll('p, div, span').forEach((element) {
        // Remove float styles that cause text to wrap incorrectly
        final style = element.attributes['style'];
        if (style != null &&
            (style.contains('float') ||
                style.contains('clear') ||
                style.contains('width'))) {
          element.attributes.remove('style');
        }
      });

      return doc.body?.innerHtml ?? '<p>Không thể xử lý nội dung.</p>';
    } else {
      return '<p>Không thể tải nội dung bài viết. Vui lòng thử lại sau. (Mã lỗi: ${response.statusCode})</p>';
    }
  } on SocketException {
    return '<p>⚠️ Không có kết nối mạng. Vui lòng kiểm tra kết nối WiFi/3G/4G của bạn và thử lại.</p>';
  } on HttpException {
    return '<p>⚠️ Lỗi kết nối đến máy chủ. Vui lòng thử lại sau.</p>';
  } on FormatException {
    return '<p>⚠️ Đường dẫn bài viết không đúng định dạng.</p>';
  } catch (e) {
    return '<p>⚠️ Không thể tải nội dung: ${_getUserFriendlyErrorMessage(e)}. Vui lòng thử lại sau.</p>';
  }
}

/// Convert technical error messages to user-friendly Vietnamese messages
String _getUserFriendlyErrorMessage(dynamic error) {
  final errorString = error.toString().toLowerCase();

  if (errorString.contains('failed host lookup') ||
      errorString.contains('socketexception')) {
    return 'Không có kết nối mạng';
  } else if (errorString.contains('timeout')) {
    return 'Hết thời gian chờ kết nối';
  } else if (errorString.contains('connection refused')) {
    return 'Máy chủ từ chối kết nối';
  } else if (errorString.contains('certificate') ||
      errorString.contains('ssl')) {
    return 'Lỗi bảo mật kết nối';
  } else if (errorString.contains('no route to host')) {
    return 'Không thể kết nối đến máy chủ';
  } else {
    return 'Lỗi không xác định';
  }
}

String extractTextFromHtml(String htmlString) {
  final document = parser.parse(htmlString);
  final String parsedString =
      parser.parse(document.body?.text).documentElement?.text ?? '';
  return parsedString.trim();
}
