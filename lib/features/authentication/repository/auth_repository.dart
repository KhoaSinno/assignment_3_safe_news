import 'package:assignment_3_safe_news/features/profile/model/achievement_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../profile/model/user_achievement_stats_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tạo document user mặc định với achievement "newbie" nếu chưa tồn tại
  Future<void> _createDefaultUserDocument(String userId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // Tạo UserAchievementStatsModel mặc định với achievement "newbie"
      final defaultStats = UserAchievementStatsModel(
        userId: userId,
        articlesRead: 0,
        currentStreak: 0,
        lastReadDate: DateTime.now(),
        readCategories: [],
        unlockedAchievements: [
          Achievement.newbie,
        ],
        updatedAt: DateTime.now(),
      );

      //  merge: true để không override data hiện có
      await userDoc.set(defaultStats.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating default user document: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        return UserModel(id: user.uid, email: user.email ?? '');
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    // Tạo document user mặc định nếu chưa có (có thể lần đầu login Google)
    final user = userCredential.user;
    if (user != null) {
      await _createDefaultUserDocument(user.uid);
    }

    return userCredential;
  }

  Future<UserModel?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await _createDefaultUserDocument(user.uid);
        return UserModel(id: user.uid, email: user.email ?? '');
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
