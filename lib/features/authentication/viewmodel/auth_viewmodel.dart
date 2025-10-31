import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:assignment_3_safe_news/utils/logger.dart';
import '../repository/auth_repository.dart';
import '../model/user_model.dart';

final authViewModelProvider = ChangeNotifierProvider((ref) {
  return AuthViewModel();
});

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  UserModel? _user;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isInitialized => _isInitialized;

  AuthViewModel() {
    // Khôi phục session ngay lập tức (synchronous) từ currentUser
    _initializeAuthState();

    // Lắng nghe thay đổi auth state từ Firebase
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null && firebaseUser.email != null) {
        _user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
        AppLogger.debug(
          'Auth state changed: User logged in - ${firebaseUser.email}',
          tag: 'AuthViewModel',
        );
      } else {
        _user = null;
        AppLogger.debug(
          'Auth state changed: User logged out',
          tag: 'AuthViewModel',
        );
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// Khôi phục trạng thái đăng nhập ngay lập tức (synchronous)
  void _initializeAuthState() {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != null) {
        _user = UserModel(
          id: currentUser.uid,
          email: currentUser.email!,
          name: currentUser.displayName,
          photoUrl: currentUser.photoURL,
        );
        AppLogger.debug(
          'Restored user session immediately: ${currentUser.email}',
          tag: 'AuthViewModel',
        );
      } else {
        _user = null;
      }
      _isInitialized = true;
    } catch (e) {
      AppLogger.error(
        'Error initializing auth state: $e',
        tag: 'AuthViewModel',
      );
      _isInitialized = true;
    }
  }

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
      AppLogger.debug('User signed out successfully', tag: 'AuthViewModel');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error signing out: $e', tag: 'AuthViewModel');
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
        AppLogger.debug(
          'User photo URL: ${userCredential.user!.photoURL}',
          tag: 'AuthViewModel',
        );
      } else {
        throw Exception('Google sign-in failed');
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
