import 'quest_model.dart';

class QuestService {
  static List<Quest> getDailyQuests() {
    return [
      Quest(
        id: 'q1',
        title: 'Code for 1 hour',
        type: QuestType.daily,
        difficulty: Difficulty.medium,
        stat: 'INT',
      ),
      Quest(
        id: 'q2',
        title: 'Workout 30 minutes',
        type: QuestType.daily,
        difficulty: Difficulty.medium,
        stat: 'STR',
      ),
      Quest(
        id: 'q3',
        title: 'Sleep before 12',
        type: QuestType.daily,
        difficulty: Difficulty.easy,
        stat: 'VIT',
      ),
    ];
  }
}
