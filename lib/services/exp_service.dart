import '../features/quests/quest_model.dart';

class ExpService {
  static int expForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 25;
      case Difficulty.hard:
        return 50;
      case Difficulty.boss:
        return 100;
    }
  }
}
