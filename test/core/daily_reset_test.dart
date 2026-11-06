import 'package:flutter_test/flutter_test.dart';
import 'package:statveil/core/utils/daily_reset.dart';
import 'package:statveil/features/quests/quest_service.dart';
import 'package:statveil/models/hunter.dart';

void main() {
  final quests = QuestService.getDailyQuests();
  final allIds = quests.map((q) => q.id).toSet();
  final yesterday = DateTime.now().subtract(const Duration(days: 1));

  group('shouldReset', () {
    test('is false later on the same day', () {
      expect(DailyReset.shouldReset(DateTime.now()), isFalse);
    });

    test('is true once the day has changed', () {
      expect(DailyReset.shouldReset(yesterday), isTrue);
    });
  });

  group('resetDay', () {
    test('finishing every quest extends the streak', () {
      final hunter = Hunter(streak: 2, completedQuestIds: {...allIds});

      DailyReset.resetDay(hunter: hunter, dailyQuests: quests);

      expect(hunter.streak, 3);
    });

    test('missing some quests costs exp and breaks the streak', () {
      final hunter = Hunter(
        currentExp: 50,
        streak: 2,
        completedQuestIds: {allIds.first},
      );

      DailyReset.resetDay(hunter: hunter, dailyQuests: quests);

      expect(hunter.level, 1);
      expect(hunter.currentExp, 30);
      expect(hunter.streak, 0);
    });

    test('missing every quest drops a level', () {
      final hunter = Hunter(level: 2, currentExp: 50, streak: 2);

      DailyReset.resetDay(hunter: hunter, dailyQuests: quests);

      expect(hunter.level, 1);
      expect(hunter.currentExp, 0);
    });

    test('rollOver resets and reports true once the day has changed', () {
      final hunter = Hunter(
        lastUpdated: yesterday,
        completedQuestIds: {...allIds},
      );

      final rolled = DailyReset.rollOver(hunter, quests);

      expect(rolled, isTrue);
      expect(hunter.streak, 1);
      expect(hunter.completedQuestIds, isEmpty);
    });

    test('rollOver leaves the same day untouched', () {
      final hunter = Hunter(completedQuestIds: {allIds.first});

      final rolled = DailyReset.rollOver(hunter, quests);

      expect(rolled, isFalse);
      expect(hunter.completedQuestIds, {allIds.first});
    });

    test('starts the new day with no completed quests', () {
      final hunter = Hunter(
        lastUpdated: yesterday,
        completedQuestIds: {...allIds},
      );

      DailyReset.resetDay(hunter: hunter, dailyQuests: quests);

      expect(hunter.completedQuestIds, isEmpty);
      expect(DailyReset.shouldReset(hunter.lastUpdated), isFalse);
    });
  });
}
