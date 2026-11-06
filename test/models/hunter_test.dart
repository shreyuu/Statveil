import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statveil/models/hunter.dart';

void main() {
  group('gainExp', () {
    test('raises only the matching stat', () {
      final hunter = Hunter();

      hunter.gainExp(10, Stat.intelligence);

      expect(hunter.intStat, 2);
      expect([hunter.str, hunter.agi, hunter.vit, hunter.will], [1, 1, 1, 1]);
      expect(hunter.currentExp, 10);
    });

    test('levels up and carries leftover exp', () {
      final hunter = Hunter(currentExp: 90);

      hunter.gainExp(25, Stat.str);

      expect(hunter.level, 2);
      expect(hunter.currentExp, 15);
      expect(hunter.expToNextLevel, 200);
    });

    test('levels up more than once for a large gain', () {
      final hunter = Hunter();

      // 350 exp: 100 to reach level 2, then 200 to reach level 3, 50 left over.
      hunter.gainExp(350, Stat.str);

      expect(hunter.level, 3);
      expect(hunter.currentExp, 50);
      expect(hunter.expToNextLevel, 300);
    });
  });

  group('completeQuest', () {
    test('awards exp and records the quest the first time', () {
      final hunter = Hunter();

      final awarded = hunter.completeQuest('q1', exp: 25, stat: Stat.str);

      expect(awarded, isTrue);
      expect(hunter.currentExp, 25);
      expect(hunter.completedQuestIds, {'q1'});
    });

    test('ignores a quest already completed today', () {
      final hunter = Hunter(completedQuestIds: {'q1'});

      final awarded = hunter.completeQuest('q1', exp: 25, stat: Stat.str);

      expect(awarded, isFalse);
      expect(hunter.currentExp, 0);
      expect(hunter.str, 1);
    });
  });

  group('applyPenalty', () {
    test('missing every quest drops a level and resets exp and streak', () {
      final hunter = Hunter(level: 3, currentExp: 40, streak: 5);

      hunter.applyPenalty(allMissed: true);

      expect(hunter.level, 2);
      expect(hunter.currentExp, 0);
      expect(hunter.streak, 0);
    });

    test('missing some quests costs 20 exp without going negative', () {
      final hunter = Hunter(currentExp: 10, streak: 2);

      hunter.applyPenalty(allMissed: false);

      expect(hunter.level, 1);
      expect(hunter.currentExp, 0);
      expect(hunter.streak, 0);
    });
  });

  group('toMap / fromMap', () {
    test('round-trips every field', () {
      final original = Hunter(
        level: 4,
        currentExp: 30,
        expToNextLevel: 400,
        str: 2,
        intStat: 3,
        agi: 4,
        vit: 5,
        will: 6,
        streak: 7,
        lastUpdated: DateTime(2026, 11, 5, 9, 30),
        completedQuestIds: {'q1', 'q3'},
      );

      final copy = Hunter.fromMap(original.toMap());

      expect(copy.toMap(), original.toMap());
    });

    test('reads documents saved before completedQuestIds existed', () {
      final saved = {
        'level': 2,
        'currentExp': 5,
        'expToNextLevel': 200,
        'str': 3,
        'int': 4,
        'agi': 1,
        'vit': 1,
        'will': 1,
        'streak': 1,
        'lastUpdated': Timestamp.fromDate(DateTime(2026, 1, 15)),
      };

      final hunter = Hunter.fromMap(saved);

      expect(hunter.intStat, 4);
      expect(hunter.lastUpdated, DateTime(2026, 1, 15));
      expect(hunter.completedQuestIds, isEmpty);
    });

    test('falls back to defaults for an empty document', () {
      final hunter = Hunter.fromMap({});

      expect(hunter.level, 1);
      expect(hunter.expToNextLevel, 100);
      expect(hunter.completedQuestIds, isEmpty);
    });
  });
}
