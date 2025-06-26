import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_acticle.dart';
import 'package:assignment_3_safe_news/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authViewModel.signUp(
                    _emailController.text,
                    _passwordController.text,
                  );

                  // Check if the widget is still mounted before showing SnackBar or navigating
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng ký thành công!')),
                  );

                  // Check if the widget is still mounted
                  if (!context.mounted) return;

                  Navigator.pushReplacement(
                    // Consider using pushReplacement to avoid going back to signup
                    context,
                    MaterialPageRoute(builder: (context) => HomeArticle()),
                  );
                } catch (e) {
                  // Check if the widget is still mounted
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng ký thất bại: $e')),
                  );
                  AppLogger.error('Đăng ký thất bại: $e', tag: 'SignupScreen');
                }
              },
              child: Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}
