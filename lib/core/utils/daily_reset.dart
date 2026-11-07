import '../../models/hunter.dart';
import '../../features/quests/quest_model.dart';

class DailyReset {
  static bool shouldReset(DateTime lastUpdated) {
    final now = DateTime.now();
    return now.day != lastUpdated.day ||
        now.month != lastUpdated.month ||
        now.year != lastUpdated.year;
  }

  /// Resets the day if it has changed since [Hunter.lastUpdated]; true if it did.
  static bool rollOver(Hunter hunter, List<Quest> dailyQuests) {
    if (!shouldReset(hunter.lastUpdated)) return false;
    resetDay(hunter: hunter, dailyQuests: dailyQuests);
    return true;
  }

  /// Scores the last active day, then charges a full miss for each untouched day since.
  static void resetDay({
    required Hunter hunter,
    required List<Quest> dailyQuests,
  }) {
    final now = DateTime.now();

    // With no quests there is nothing to score, so no free streak and no penalty.
    if (dailyQuests.isNotEmpty) {
      final missed = dailyQuests
          .where((q) => !hunter.completedQuestIds.contains(q.id))
          .length;

      if (missed == 0) {
        hunter.incrementStreak();
      } else {
        hunter.applyPenalty(allMissed: missed == dailyQuests.length);
      }

      final skippedDays = _calendarDaysBetween(hunter.lastUpdated, now) - 1;
      for (var day = 0; day < skippedDays; day++) {
        hunter.applyPenalty(allMissed: true);
      }
    }

    hunter.completedQuestIds.clear();
    hunter.lastUpdated = now;
  }

  // UTC dates so a DST change can't turn a calendar day into 23 hours.
  static int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
    to.year,
    to.month,
    to.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
}
