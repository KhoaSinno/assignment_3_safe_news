import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chính sách bảo mật',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chính sách bảo mật',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cập nhật lần cuối: 25/06/2025',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Giới thiệu',
              'Chúng tôi cam kết bảo vệ quyền riêng tư và thông tin cá nhân của bạn. Chính sách bảo mật này giải thích cách chúng tôi thu thập, sử dụng, lưu trữ và bảo vệ thông tin của bạn khi sử dụng ứng dụng Safe News.',
            ),

            _buildSection(
              context,
              'Thông tin chúng tôi thu thập',
              '''• Thông tin tài khoản: Tên, email, mật khẩu khi bạn đăng ký tài khoản
• Thông tin sử dụng: Các bài báo bạn đọc, bookmark, thời gian sử dụng ứng dụng
• Thông tin thiết bị: Loại thiết bị, hệ điều hành, phiên bản ứng dụng
• Thông tin vị trí: Để cung cấp tin tức địa phương (chỉ khi bạn cho phép)''',
            ),

            _buildSection(
              context,
              'Cách chúng tôi sử dụng thông tin',
              '''• Cung cấp và cải thiện dịch vụ ứng dụng
• Cá nhân hóa nội dung tin tức theo sở thích của bạn
• Gửi thông báo về tin tức mới và cập nhật ứng dụng
• Phân tích và cải thiện hiệu suất ứng dụng
• Đảm bảo an ninh và ngăn chặn gian lận''',
            ),

            _buildSection(
              context,
              'Chia sẻ thông tin',
              '''Chúng tôi không bán, cho thuê hoặc chia sẻ thông tin cá nhân của bạn với bên thứ ba, trừ trong các trường hợp sau:
• Khi có sự đồng ý rõ ràng từ bạn
• Để tuân thủ pháp luật hoặc yêu cầu từ cơ quan có thẩm quyền
• Để bảo vệ quyền lợi và an toàn của chúng tôi và người dùng''',
            ),

            _buildSection(
              context,
              'Bảo mật thông tin',
              '''Chúng tôi áp dụng các biện pháp bảo mật kỹ thuật và tổ chức phù hợp để bảo vệ thông tin của bạn:
• Mã hóa dữ liệu trong quá trình truyền tải
• Lưu trữ an toàn trên máy chủ được bảo mật
• Kiểm soát quyền truy cập nghiêm ngặt
• Giám sát liên tục để phát hiện và ngăn chặn vi phạm''',
            ),

            _buildSection(context, 'Quyền của bạn', '''Bạn có quyền:
• Truy cập và xem thông tin cá nhân của mình
• Chỉnh sửa hoặc cập nhật thông tin
• Xóa tài khoản và dữ liệu liên quan
• Từ chối việc thu thập một số loại thông tin
• Khiếu nại về việc xử lý dữ liệu cá nhân'''),

            _buildSection(
              context,
              'Cookie và công nghệ theo dõi',
              'Ứng dụng có thể sử dụng cookie và các công nghệ tương tự để cải thiện trải nghiệm người dùng, phân tích việc sử dụng ứng dụng và cung cấp nội dung phù hợp.',
            ),

            _buildSection(
              context,
              'Thay đổi chính sách',
              'Chúng tôi có thể cập nhật chính sách bảo mật này theo thời gian. Mọi thay đổi quan trọng sẽ được thông báo cho bạn qua ứng dụng hoặc email.',
            ),

            _buildSection(
              context,
              'Liên hệ',
              '''Nếu bạn có câu hỏi về chính sách bảo mật này, vui lòng liên hệ:
      • Email: safenews@gmail.com
      • Điện thoại: +84 123 456 789
      • Địa chỉ: 256 Nguyễn Văn Cừ, Ninh Kiều, TP.Cần Thơ''',
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bằng việc sử dụng ứng dụng Safe News, bạn đồng ý với các điều khoản trong chính sách bảo mật này.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
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

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontSize: 14, height: 1.6),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
