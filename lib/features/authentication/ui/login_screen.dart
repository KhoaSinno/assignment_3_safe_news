import 'package:assignment_3_safe_news/features/authentication/ui/signup_screen.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/auth_viewmodel.dart';

class LoginScreen extends ConsumerWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginScreen({super.key});
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
                  await authViewModel.signIn(
                    _emailController.text,
                    _passwordController.text,
                  );
                  print('Đăng nhập thành công: ${authViewModel.user?.email}');

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng nhập thất bại: $e')),
                  );
                  print('Đăng nhập thất bại: $e');
                }
              },
              child: Text('Đăng nhập'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text('Đăng ký'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authViewModel.signInWithGoogle();
                  print(
                    'Đăng nhập bằng Google thành công: ${authViewModel.user?.email}',
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đăng nhập bằng Google thất bại: $e'),
                    ),
                  );
                  print('Đăng nhập bằng Google thất bại: $e');
                }
              },
              child: Text('Đăng nhập bằng Google'),
            ),
          ],
        ),
      ),
    );
  }
}
