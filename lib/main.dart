import 'package:assignment_3_safe_news/features/authentication/ui/login_screen.dart';
import 'package:assignment_3_safe_news/features/authentication/viewmodel/auth_viewmodel.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_acticle.dart';
import 'package:assignment_3_safe_news/features/home/ui/home_screen.dart';
import 'package:assignment_3_safe_news/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ProviderScope(child: SafeNewsApp()));
}

class SafeNewsApp extends ConsumerWidget {
  const SafeNewsApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.watch(authViewModelProvider);

    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: authViewModel.user != null ? LoginScreen() : MainScreen(),
    );
  }
}
