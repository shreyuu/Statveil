import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hunter.dart';
import 'auth_service.dart';

class HunterService {
  static final _hunters = FirebaseFirestore.instance.collection('hunters');

  /// Loads the signed-in user's hunter, or a fresh one if nothing is saved yet.
  static Future<Hunter> loadHunter() async {
    final user = await AuthService.signInAnon();
    final data = (await _hunters.doc(user.uid).get()).data();
    return data == null ? Hunter() : Hunter.fromMap(data);
  }

  static Future<void> saveHunter(Hunter hunter) async {
    final user = await AuthService.signInAnon();
    await _hunters.doc(user.uid).set(hunter.toMap());
  }
}
