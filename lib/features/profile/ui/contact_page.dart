import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liên hệ',
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
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.contact_support, size: 64, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy liên hệ với chúng tôi qua các kênh dưới đây',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Methods
            Text(
              'Thông tin liên hệ',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactItem(
              context,
              icon: Icons.email,
              title: 'Email',
              subtitle: 'support@safenews.com',
              description: 'Gửi email cho chúng tôi bất cứ lúc nào',
              onTap: () => _launchEmail('support@safenews.com'),
            ),

            _buildContactItem(
              context,
              icon: Icons.phone,
              title: 'Điện thoại',
              subtitle: '+84 123 456 789',
              description: 'Thời gian hỗ trợ: 8:00 - 22:00 (T2-CN)',
              onTap: () => _launchPhone('+84123456789'),
            ),

            _buildContactItem(
              context,
              icon: Icons.location_on,
              title: 'Địa chỉ văn phòng',
              subtitle: '256 Nguyễn Văn Cừ',
              description: 'Ninh Kiều, TP. Cần Thơ, Việt Nam',
              onTap: () => _launchMaps(),
            ),

            _buildContactItem(
              context,
              icon: Icons.access_time,
              title: 'Giờ làm việc',
              subtitle: 'Thứ 2 - Chủ nhật',
              description: '8:00 AM - 10:00 PM',
              onTap: null,
            ),

            const SizedBox(height: 32),

            // Social Media
            Text(
              'Theo dõi chúng tôi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(
                  context,
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => _launchUrl('https://facebook.com/safenews'),
                ),
                _buildSocialButton(
                  context,
                  icon: Icons.send, // Telegram icon substitute
                  label: 'Twitter',
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _launchUrl('https://twitter.com/safenews'),
                ),
                _buildSocialButton(
                  context,
                  icon: Icons.camera_alt, // Instagram icon substitute
                  label: 'Instagram',
                  color: const Color(0xFFE4405F),
                  onTap: () => _launchUrl('https://instagram.com/safenews'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Câu hỏi thường gặp',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              context,
              question: 'Làm thế nào để bookmark một bài báo?',
              answer:
                  'Bạn có thể nhấn vào biểu tượng bookmark (⭐) ở góc phải trên của bài báo để lưu vào danh sách yêu thích.',
            ),

            _buildFAQItem(
              context,
              question: 'Tôi có thể đọc báo offline không?',
              answer:
                  'Có, các bài báo đã bookmark sẽ được lưu trữ offline để bạn có thể đọc khi không có kết nối internet.',
            ),

            _buildFAQItem(
              context,
              question: 'Làm thế nào để thay đổi chế độ giao diện?',
              answer:
                  'Vào Hồ sơ cá nhân > Cài đặt > Chế độ tối để chuyển đổi giữa giao diện sáng và tối.',
            ),

            const SizedBox(height: 32),

            // Contact Form Hint
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.feedback,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gửi phản hồi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ý kiến của bạn rất quan trọng với chúng tôi. Hãy gửi email để chia sẻ trải nghiệm và đề xuất cải thiện ứng dụng.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launchEmail('feedback@safenews.com'),
                    icon: const Icon(Icons.send),
                    label: const Text('Gửi phản hồi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
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

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing:
            onTap != null
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                )
                : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Liên hệ từ Safe News App',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      print('Could not launch email: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      print('Could not launch phone: $e');
    }
  }

  Future<void> _launchMaps() async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=123+Nguyen+Van+Cu+District+5+Ho+Chi+Minh+City',
    );

    try {
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch maps: $e');
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not launch URL: $e');
    }
  }
}
