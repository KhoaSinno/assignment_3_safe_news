import 'dart:ui'; // Required for ImageFilter.blur

import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart'; // Import HtmlWidget
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:intl/intl.dart';

class DetailArticle extends StatefulWidget {
  const DetailArticle({super.key, required this.article});
  final ArticleModel article;

  @override
  _DetailArticleState createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  Future<String> fetchArticleContent({
    String url =
        'https://vnexpress.net/mark-zuckerberg-lap-doi-phat-trien-sieu-tri-tue-agi-4897184.html',
  }) async {
    final response = await http.get(Uri.parse(url));
    print('Fetching article content from: $url'); // Log the actual URL being fetched
    // print('Status code: ${response.statusCode}'); // Keep for debugging if needed
    // print('Response body: ${response.body}'); // Keep for debugging if needed

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final contentElement = document.querySelector('.fck_detail');
      // Return the outer HTML of the element, or a default message if not found
      final content = contentElement?.outerHtml ?? '<p>Không tìm thấy nội dung chi tiết.</p>';
      return content;
    } else {
      throw Exception('Không thể tải nội dung bài viết. Mã lỗi: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // fetchArticleContent(); // Remove this line, FutureBuilder handles it

    return Scaffold(
      // extendBodyBehindAppBar: true, // Allows body to go behind AppBar
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        // Use Stack to layer blur effect and content
        children: [
          // Frosted glass effect
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(
                  0.1,
                ), // Adjust opacity for desired effect
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.article.imageUrl),
                      fit: BoxFit.cover,
                      // Add errorBuilder for image loading
                      onError: (exception, stackTrace) {
                        // Optionally, log the error: print('Error loading image: $exception');
                      },
                    ),
                  ),
                  // Display a placeholder or icon if image fails to load
                  child:
                      widget.article.imageUrl.isEmpty ||
                              Uri.tryParse(
                                    widget.article.imageUrl,
                                  )?.hasAbsolutePath !=
                                  true
                          ? Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                          : null, // Or Image.network with errorBuilder if you prefer that syntax
                ),
                Container(
                  transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          // CircleAvatar(
                          //   radius: 12,
                          //   backgroundImage: NetworkImage(
                          //     "https://placehold.co/24x24",
                          //   ),
                          // ),
                          // SizedBox(width: 8),
                          Text(
                            // 'Anh Khoa · Thứ 3 ngày 10 năm 2025',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(widget.article.published).toString(),
                            style: TextStyle(
                              color: const Color(0xFF6D6265),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Bản tóm tắt',
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 20,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Bài báo kể về hành trình đầy nỗ lực của Trần Trung Đức, một chàng trai từ Lai Châu, Việt Nam, vượt qua nhiều khó khăn để trở thành thạc sĩ xuất sắc tại Đại học Ngôn ngữ Bắc Kinh. Sau khi tốt nghiệp THPT, anh thử sức với nhiều ngành nghề nhưng không tìm được việc làm ổn định. Cuối cùng, anh quyết định học tiếng Trung, bắt đầu từ việc tự học và tham gia các khóa đào tạo tại Trung Quốc.\nNhờ sự kiên trì, anh đạt thành tích xuất sắc, giành học bổng tại Đại học Sư phạm Vân Nam, rồi tiếp tục học thạc sĩ tại Đại học Ngôn ngữ Bắc Kinh với GPA 3.94/4, nằm trong top 4% sinh viên xuất sắc của trường. Luận văn thạc sĩ của anh tập trung vào các lỗi phát âm tiếng Trung của người Việt và cách chỉnh sửa. Hiện tại, anh là giáo viên tiếng Trung trực tuyến và dự định xin học bổng tiến sĩ tại Đại học Bắc Kinh.',
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 16,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Chi tiết bài báo',
                        style: TextStyle(
                          color: const Color(0xFF231F20),
                          fontSize: 20,
                          fontFamily: 'Aleo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                     
                      SizedBox(height: 24),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage("https://placehold.co/366x310"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Anh Đức dành một góc trong nhà để trưng bày giấy khen, giấy chứng nhận từ các cuộc thi. Ảnh: Nhân vật cung cấp',
                        style: TextStyle(
                          color: const Color(0xFF6D6265),
                          fontSize: 14,
                          fontFamily: 'Merriweather',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 24),
                      // FutureBuilder to display fetched HTML article content
                      FutureBuilder<String>(
                        future: fetchArticleContent(url: widget.article.link!), 

                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());

                          } else if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Lỗi tải nội dung: ${snapshot.error}'),
                            );

                          } else if (snapshot.hasData) {
                            // Use HtmlWidget to render the HTML content
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),

                              child: HtmlWidget(
                                snapshot.data!,
                                textStyle: TextStyle( // Default text style for content not otherwise styled by HTML
                                  color: const Color(0xFF231F20),
                                  fontSize: 16,
                                  fontFamily: 'Merriweather',
                                  fontWeight: FontWeight.w400,
                                ),
                                // You can add more configurations to HtmlWidget as needed
                                // For example, to handle image loading errors within the HTML:
                                onLoadingBuilder: (context, element, loadingProgress) => Center(child: CircularProgressIndicator()),
                                onErrorBuilder: (context, element, error) => Text('Lỗi hiển thị phần tử: ${element.localName}', style: TextStyle(color: Colors.red)),
                              ),
                            );

                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Không có nội dung chi tiết để hiển thị.'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
