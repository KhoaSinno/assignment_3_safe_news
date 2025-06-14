import 'package:flutter/material.dart';

class DetailArticle extends StatefulWidget {
  const DetailArticle({super.key, required this.article});
  final dynamic article;

  @override
  _DetailArticleState createState() => _DetailArticleState();
}

class _DetailArticleState extends State<DetailArticle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x99F3EBE9),
        // elevation: 0,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://placehold.co/430x316"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -50.0, 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Từ chàng trai thất nghiệp thành thạc sĩ đại học hàng đầu Trung Quốc',
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
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(
                          "https://placehold.co/24x24",
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Anh Khoa · Thứ 3 ngày 10 năm 2025',
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
                  SizedBox(height: 8),
                  Text(
                    'Từ quê Lai Châu đi học nghề rồi không xin được việc, Trung Đức vừa bán hàng vừa học tiếng Trung, bôn ba chục năm trời trước khi tốt nghiệp xuất sắc thạc sĩ Đại học Ngôn ngữ Bắc Kinh.\nTrần Trung Đức, 32 tuổi, tốt nghiệp thạc sĩ ngành Giáo dục Hán ngữ quốc tế, Đại học Ngôn ngữ Bắc Kinh, hồi tháng 7/2024, với điểm trung bình học tập (GPA) 3.94/4 - top 4% sinh viên xuất sắc của trường. Ngôi trường này là cơ sở đào tạo Hán ngữ và văn hóa Trung Quốc lâu đời và quy mô nhất.\n"Tôi chưa từng nghĩ đến được ngày hôm nay", anh Đức, hiện là giáo viên tiếng Trung online, nói. "9 năm trước, tôi vẫn loay hoay tìm hướng đi".\nNăm 2011, sau khi tốt nghiệp THPT, Đức xuống Hà Nội học sửa chữa điện thoại vì thấy nghề này đang "thịnh", dễ kiếm tiền. Nhưng học xong không xin được việc, anh đăng ký Cao đẳng Y tế Phú Thọ, ngành Y đa khoa, theo định hướng của mẹ.\nTốt nghiệp với tấm bằng giỏi, Đức vẫn thất nghiệp nên về quê, xin làm nhân viên siêu thị ở cửa khẩu Ma Lù Thàng. Tại đây, anh học tiếng Trung vì tiếp xúc hàng ngày với khách Trung Quốc.\nMuốn có cơ hội xin học bổng du học nên năm 2016, Đức quyết định sang trường Cao cấp nghề Hà Khẩu ở Trung Quốc học một năm tiếng. Anh học bằng cách chép bài khóa vào vở, sau đó nghe audio từng câu rồi dừng lại để đọc, nói theo, viết ra và đối chiếu bản gốc. Cứ như vậy, Đức viết tới không còn lỗi mới thôi.\n"Cách này luyện được cả 4 kỹ năng", anh Đức nhớ lại. Là người gốc Hoa, anh Đức nhìn nhận có lợi thế hơn so với các bạn ở khả năng nghe, nói.\nKhi đã đọc hiểu tốt hơn, anh luyện đề HSK (chứng chỉ năng lực tiếng Trung), đọc các tác phẩm văn học và nhiều tài liệu bên ngoài để nâng cao kiến thức. Nhờ chăm chỉ, ngoài đạt kết quả học tập xuất sắc, anh Đức còn giành giải nhất cuộc thi khẩu ngữ của trường.\nTham gia các diễn đàn, hội nhóm học tiếng Trung, anh Đức nhận thấy nhiều người gặp khó ở phát âm. Đó là lý do anh nộp đơn xin học bổng miễn học phí của Đại học Sư phạm Vân Nam, theo đuổi ngành Giáo dục Hán ngữ Quốc tế. Ở tuổi 26, anh bắt đầu học đại học và được học thẳng lên năm thứ hai vì đạt điểm tốt bài kiểm tra vượt cấp.\nNăm 2021, anh lọt top 27 cuộc thi diễn thuyết COP 15 về bảo vệ tính đa dạng sinh học toàn cầu tổ chức ở Côn Minh. Ngoài ra, anh cũng đạt giải nhất toàn tỉnh Vân Nam và giải khuyến khích toàn quốc khối du học sinh về ngâm thơ.\nTốt nghiệp với GPA 3.99/4, anh Đức tiếp tục giành học bổng để học thạc sĩ tại Đại học Ngôn ngữ Bắc Kinh. Đề tài luận văn thạc sĩ của anh tập trung tìm hiểu các lỗi phát âm cơ bản của người Việt và cách chỉnh sửa.\nTheo anh Đức, các âm /p/, / h/, /z, c/, /j, q, x/, /zh, ch, sh, r/ trong tiếng Trung không có âm tương tự trong tiếng Việt. Nên khi phát âm, người nói thường lấy âm gần giống nhất trong hệ ngữ âm của mình để phát âm, dẫn đến sai.\n"Cách chỉnh là dựa trên những điểm tương đồng hoặc tiệm cận giữa hai hệ ngữ âm", anh giải thích.',
                    style: TextStyle(
                      color: const Color(0xFF231F20),
                      fontSize: 16,
                      fontFamily: 'Merriweather',
                      fontWeight: FontWeight.w400,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
