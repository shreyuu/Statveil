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

  // shortcut: a multi-day gap is scored as one missed day; penalise each day if that matters.
  static void resetDay({
    required Hunter hunter,
    required List<Quest> dailyQuests,
  }) {
    final missed = dailyQuests
        .where((q) => !hunter.completedQuestIds.contains(q.id))
        .length;

    if (missed == 0) {
      hunter.incrementStreak();
    } else {
      hunter.applyPenalty(allMissed: missed == dailyQuests.length);
    }

    hunter.completedQuestIds.clear();
    hunter.lastUpdated = DateTime.now();
  }
}
