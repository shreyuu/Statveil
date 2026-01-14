import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hunter.dart';

class HunterService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveHunter(Hunter hunter) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _db.collection('hunters').doc(uid).set({
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
