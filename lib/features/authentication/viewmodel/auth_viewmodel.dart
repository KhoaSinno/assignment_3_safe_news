import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:assignment_3_safe_news/utils/logger.dart';
import '../repository/auth_repository.dart';
import '../model/user_model.dart';

final authViewModelProvider = ChangeNotifierProvider((ref) => AuthViewModel());

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      print('🔑 Signing in with email: $email');
      _user = await _authRepository.signIn(email, password);
      print('✅ SignIn completed for: ${_user?.email}');

      notifyListeners();
    } catch (e) {
      print('❌ SignIn error: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _user = await _authRepository.signUp(email, password);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print('🔓 Signing out user: ${_user?.email}');
      await _authRepository.signOut();
      _user = null;

      notifyListeners();
      print('✅ SignOut completed');
    } catch (e) {
      print('❌ SignOut error: $e');
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      print('🔑 Signing in with Google');
      final UserCredential userCredential =
          await _authRepository.signInWithGoogle();
      if (userCredential.user != null && userCredential.user!.email != null) {
        _user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
        );
        print('✅ Google SignIn completed for: ${_user?.email}');
        AppLogger.debug(
          'User photo URL: ${userCredential.user!.photoURL}',
          tag: 'AuthViewModel',
        );
      } else {
        throw Exception('Google sign-in failed');
      }

      notifyListeners();
    } catch (e) {
      print('❌ Google SignIn error: $e');
      rethrow;
    }
  }
}
