import 'dart:ui';

import 'package:assignment_3_safe_news/features/home/model/article_model.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';

class DetailArticle extends StatefulWidget {
  const DetailArticle({super.key, required this.article});
  final ArticleModel article;

  @override
  _DetailArticleState createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  String? _summary;
  bool _isLoadingSummary = false;

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    if (mounted) {
      setState(() {
        _isLoadingSummary = true;
      });
    }
    try {
      final content = await fetchArticleContent(url: widget.article.link);
      // Extract text from HTML
      final plainTextContent = _extractTextFromHtml(content);
      if (plainTextContent.isNotEmpty) {
        final summary = await summaryContentGemini(plainTextContent);
        if (mounted) {
          setState(() {
            _summary = summary;
            _isLoadingSummary = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _summary = "Không thể trích xuất nội dung để tóm tắt.";
            _isLoadingSummary = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _summary = "Lỗi khi tóm tắt nội dung: $e";
          _isLoadingSummary = false;
        });
      }
      // Optionally, log the error
      print('Error generating summary: $e');
    }
  }

  String _extractTextFromHtml(String htmlString) {
    final document = parser.parse(htmlString);
    final String parsedString =
        parser.parse(document.body?.text).documentElement?.text ?? "";
    return parsedString;
  }

  Future<String> summaryContentGemini(String content) async {
    if (content.isEmpty) {
      return "Nội dung trống, không thể tóm tắt.";
    }
    try {
      final prompt = [
        Content.text(
          'Tóm tắt nội dung sau bằng ngôn ngữ tiếng việt thành một đoạn ngắn, phong cách báo trí, mạch lạc dễ hiểu và cuốn hút: $content',
        ),
      ];

      final response = await model.generateContent(prompt);

      return response.text ?? "Không thể tạo tóm tắt.";
    } catch (e) {
      print('Error with Gemini API: $e');
      return "Lỗi khi gọi API tóm tắt.";
    }
  }

  Future<String> fetchArticleContent({required String? url}) async {
    if (url == null || url.isEmpty) {
      return '<p>Article URL is missing.</p>';
    }
    final response = await http.get(Uri.parse(url));
    print('Fetching article content from: $url');

    if (response.statusCode == 200) {
      final document = parser.parse(response.body);
      final contentElement = document.querySelector('.fck_detail');
      final String htmlContent =
          contentElement?.outerHtml ??
          '<p>Không tìm thấy nội dung chi tiết.</p>';

      // Pre-process HTML to handle data-src
      final doc = parser.parse(htmlContent);
      doc.querySelectorAll('img').forEach((imgElement) {
        final dataSrc = imgElement.attributes['data-src'];
        final src = imgElement.attributes['src'];
        if (dataSrc != null && dataSrc.isNotEmpty) {
          if (src == null ||
              src.isEmpty ||
              src.startsWith('data:image/gif;base64')) {
            imgElement.attributes['src'] = dataSrc;
          }
        }
      });
      return doc.body?.innerHtml ?? '<p>Không thể xử lý nội dung.</p>';
    } else {
      throw Exception(
        'Không thể tải nội dung bài viết. Mã lỗi: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
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
                      _isLoadingSummary
                          ? Center(child: CircularProgressIndicator())
                          : Text(
                            _summary ?? 'Đang tải tóm tắt...',
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

                      SizedBox(height: 12),
                      // FutureBuilder to display fetched HTML article content
                      FutureBuilder<String>(
                        future: fetchArticleContent(
                          url: widget.article.link,
                        ), // Use widget.article.link
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Lỗi tải nội dung: ${snapshot.error}',
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data!.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: HtmlWidget(
                                snapshot.data!,
                                textStyle: TextStyle(
                                  color: const Color(0xFF231F20),
                                  fontSize: 16,
                                  fontFamily: 'Merriweather',
                                  fontWeight: FontWeight.w400,
                                ),
                                onLoadingBuilder:
                                    (context, element, loadingProgress) =>
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                onErrorBuilder:
                                    (context, element, error) => Text(
                                      'Lỗi hiển thị: ${element.localName}',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                // Optional: Provide a base URL if some images have relative paths
                                // baseUrl: Uri.tryParse(widget.article.link ?? '')?.origin != null ? Uri.parse(Uri.parse(widget.article.link!).origin) : null,
                                customWidgetBuilder: (dom.Element element) {
                                  if (element.localName == 'img') {
                                    final src = element.attributes['src'];
                                    final dataSrc =
                                        element.attributes['data-src'];
                                    String? imageUrl = src;

                                    if (dataSrc != null && dataSrc.isNotEmpty) {
                                      // Prioritize data-src if src is a placeholder
                                      if (src == null ||
                                          src.isEmpty ||
                                          src.startsWith(
                                            'data:image/gif;base64',
                                          )) {
                                        imageUrl = dataSrc;
                                      }
                                    }

                                    if (imageUrl != null &&
                                        imageUrl.isNotEmpty) {
                                      // Ensure the URL is absolute
                                      if (!imageUrl.startsWith('http') &&
                                          widget.article.link != null) {
                                        try {
                                          Uri baseUri = Uri.parse(
                                            widget.article.link!,
                                          );
                                          imageUrl =
                                              baseUri
                                                  .resolve(imageUrl)
                                                  .toString();
                                        } catch (e) {
                                          print(
                                            'Error resolving image URL: $e',
                                          );
                                          return Text('Invalid image URL');
                                        }
                                      }

                                      return Image.network(
                                        imageUrl,
                                        loadingBuilder: (
                                          BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace,
                                        ) {
                                          print(
                                            'Error loading image in HtmlWidget: $imageUrl, Error: $exception',
                                          );
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Không thể tải ảnh',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        fit:
                                            BoxFit
                                                .cover, // Adjust fit as needed
                                      );
                                    }
                                  }
                                  // To handle videos or iframes, you might add more conditions here
                                  // if (element.localName == 'iframe') {
                                  //   final src = element.attributes['src'];
                                  //   if (src != null && src.startsWith('https://www.youtube.com/embed/')) {
                                  //     // Consider using a package like youtube_player_flutter
                                  //     return AspectRatio(
                                  //       aspectRatio: 16 / 9,
                                  //       child: WebView(initialUrl: src, javascriptMode: JavascriptMode.unrestricted),
                                  //     );
                                  //   }
                                  // }
                                  return null; // Return null to let the default rendering happen
                                },
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Không có nội dung chi tiết để hiển thị.',
                              ),
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
