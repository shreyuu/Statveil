import '../../models/hunter.dart';

enum QuestType { daily, side, boss }

enum Difficulty { easy, medium, hard, boss }

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final Difficulty difficulty;
  final Stat stat;

  const Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.stat,
  });
}
