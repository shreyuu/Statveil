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

  /// Unknown enum names (bad or newer data) fall back to defaults instead of failing the load.
  factory Quest.fromMap(Map<String, dynamic> map) => Quest(
    id: map['id'] as String? ?? '',
    title: map['title'] as String? ?? '',
    type: QuestType.values.asNameMap()[map['type']] ?? QuestType.daily,
    difficulty:
        Difficulty.values.asNameMap()[map['difficulty']] ?? Difficulty.easy,
    stat: Stat.values.asNameMap()[map['stat']] ?? Stat.str,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'type': type.name,
    'difficulty': difficulty.name,
    'stat': stat.name,
  };
}
