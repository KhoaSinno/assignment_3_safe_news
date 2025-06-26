import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

Future<String> fetchArticleContent({required String? url}) async {
  if (url == null || url.isEmpty) {
    return '<p>Article URL is missing.</p>';
  }
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
    });
    return doc.body?.innerHtml ?? '<p>Không thể xử lý nội dung.</p>';
  } else {
    throw Exception(
      'Không thể tải nội dung bài viết. Mã lỗi: ${response.statusCode}',
    );
  }
}

String extractTextFromHtml(String htmlString) {
  final document = parser.parse(htmlString);
  final String parsedString =
      parser.parse(document.body?.text).documentElement?.text ?? "";
  return parsedString.trim();
}
