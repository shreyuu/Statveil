import '../../models/hunter.dart';
import '../../features/quests/quest_model.dart';

class DailyReset {
  static bool shouldReset(DateTime lastUpdated) {
    final now = DateTime.now();
    return now.day != lastUpdated.day ||
        now.month != lastUpdated.month ||
        now.year != lastUpdated.year;
  }

  static void resetDay({
    required Hunter hunter,
    required List<Quest> dailyQuests,
  }) {
    final incomplete = dailyQuests.where((q) => !q.completed).toList();

    if (incomplete.isEmpty) {
      hunter.incrementStreak();
    } else {
      hunter.applyPenalty(allMissed: incomplete.length == dailyQuests.length);
    }

    // Reset quests
    for (final quest in dailyQuests) {
      quest.completed = false;
    }

    hunter.lastUpdated = DateTime.now();
  }
}
