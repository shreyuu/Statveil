import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hunter.dart';

class HunterService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveHunter(Hunter hunter) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // optional: print('No user yet, skipping save');
      return;
    }

    await _db.collection('hunters').doc(user.uid).set({
      'level': hunter.level,
      'currentExp': hunter.currentExp,
      'expToNextLevel': hunter.expToNextLevel,
      'str': hunter.str,
      'int': hunter.intStat,
      'agi': hunter.agi,
      'vit': hunter.vit,
      'will': hunter.will,
      'streak': hunter.streak,
      'lastUpdated': Timestamp.fromDate(hunter.lastUpdated),
    });
  }
}
