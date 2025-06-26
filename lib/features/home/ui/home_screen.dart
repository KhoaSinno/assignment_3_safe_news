import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chào mừng bạn đến với ứng dụng của chúng tôi!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (authViewModel.user != null) ...[
              Text(
                'Bạn đã đăng nhập với email: ${authViewModel.user?.email}',
                style: TextStyle(fontSize: 18),
              ),
              Column(
                children: [
                  Text(
                    authViewModel.user?.name ?? 'Tên không có sẵn',
                    style: TextStyle(fontSize: 18),
                  ),
                  Image.network(authViewModel.user?.photoUrl ?? ''),
                ],
              ),
            ] else ...[
              Text(
                'Bạn chưa đăng nhập.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
            ElevatedButton(
              onPressed: () async {
                try {
                  await authViewModel.signOut();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng xuất thành công!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đăng xuất thất bại: $e')),
                  );
                }
              },
              child: Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
