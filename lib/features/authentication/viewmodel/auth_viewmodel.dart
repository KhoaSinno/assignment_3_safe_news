import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../repository/auth_repository.dart';
import '../model/user_model.dart';

final authViewModelProvider = ChangeNotifierProvider((ref) => AuthViewModel());

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> signIn(String email, String password) async {
    try {
      _user = await _authRepository.signIn(email, password);
      notifyListeners();
    } catch (e) {
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
      await _authRepository.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final UserCredential userCredential =
          await _authRepository.signInWithGoogle();
      if (userCredential.user != null && userCredential.user!.email != null) {
        _user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName,
          photoUrl: userCredential.user!.photoURL,
        );
        print(userCredential.user!.photoURL);
      } else {
        throw Exception('Google sign-in failed');
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
