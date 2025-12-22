enum QuestType { daily, side, boss }

enum Difficulty { easy, medium, hard, boss }

class Quest {
  final String id;
  final String title;
  final QuestType type;
  final Difficulty difficulty;
  final String stat; // STR, INT, AGI, etc.
  bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.difficulty,
    required this.stat,
    this.completed = false,
  });
}
