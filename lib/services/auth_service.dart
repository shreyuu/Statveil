import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  /// Reuses the signed-in user; only creates an anonymous account when there is none.
  static Future<User> signInAnon() async {
    return _auth.currentUser ?? (await _auth.signInAnonymously()).user!;
  }
}
