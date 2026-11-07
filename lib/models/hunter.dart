import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/quests/quest_model.dart';
import '../features/quests/quest_service.dart';

enum Stat {
  str('STR'),
  intelligence('INT'),
  agi('AGI'),
  vit('VIT'),
  will('WILL');

  const Stat(this.label);
  final String label;
}

class Hunter {
  int level;
  int currentExp;
  int expToNextLevel;

  int str;
  int intStat;
  int agi;
  int vit;
  int will;

  int streak;
  DateTime lastUpdated;

  /// Quest ids completed since the last daily reset.
  final Set<String> completedQuestIds;

  /// The hunter's daily quests; stored on the same document so `set()` saves them together.
  final List<Quest> quests;

  Hunter({
    this.level = 1,
    this.currentExp = 0,
    this.expToNextLevel = 100,
    this.str = 1,
    this.intStat = 1,
    this.agi = 1,
    this.vit = 1,
    this.will = 1,
    this.streak = 0,
    DateTime? lastUpdated,
    Set<String>? completedQuestIds,
    List<Quest>? quests,
  }) : lastUpdated = lastUpdated ?? DateTime.now(),
       completedQuestIds = completedQuestIds ?? <String>{},
       // Copy: the starter list is const, and quests get added and removed.
       quests = quests ?? [...QuestService.getDailyQuests()];

  /// Field names match documents already saved in Firestore ('int', not 'intStat').
  factory Hunter.fromMap(Map<String, dynamic> map) => Hunter(
    level: map['level'] as int? ?? 1,
    currentExp: map['currentExp'] as int? ?? 0,
    expToNextLevel: map['expToNextLevel'] as int? ?? 100,
    str: map['str'] as int? ?? 1,
    intStat: map['int'] as int? ?? 1,
    agi: map['agi'] as int? ?? 1,
    vit: map['vit'] as int? ?? 1,
    will: map['will'] as int? ?? 1,
    streak: map['streak'] as int? ?? 0,
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    completedQuestIds: (map['completedQuestIds'] as List<dynamic>?)
        ?.cast<String>()
        .toSet(),
    quests: (map['quests'] as List<dynamic>?)
        ?.map((q) => Quest.fromMap(Map<String, dynamic>.from(q as Map)))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    'level': level,
    'currentExp': currentExp,
    'expToNextLevel': expToNextLevel,
    'str': str,
    'int': intStat,
    'agi': agi,
    'vit': vit,
    'will': will,
    'streak': streak,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
    'completedQuestIds': completedQuestIds.toList(),
    'quests': quests.map((q) => q.toMap()).toList(),
  };

  int statValue(Stat stat) => switch (stat) {
    Stat.str => str,
    Stat.intelligence => intStat,
    Stat.agi => agi,
    Stat.vit => vit,
    Stat.will => will,
  };

  /// Returns false (and awards nothing) if the quest was already completed today.
  bool completeQuest(String questId, {required int exp, required Stat stat}) {
    if (!completedQuestIds.add(questId)) return false;
    gainExp(exp, stat);
    return true;
  }

  void gainExp(int exp, Stat stat) {
    currentExp += exp;

    switch (stat) {
      case Stat.str:
        str++;
      case Stat.intelligence:
        intStat++;
      case Stat.agi:
        agi++;
      case Stat.vit:
        vit++;
      case Stat.will:
        will++;
    }

    while (currentExp >= expToNextLevel) {
      levelUp();
    }
  }

  void levelUp() {
    currentExp -= expToNextLevel;
    level++;
    expToNextLevel = level * 100;

    // Stat reward
    str++;
    intStat++;
    agi++;
    vit++;
    will++;
  }

  void applyPenalty({required bool allMissed}) {
    if (allMissed) {
      if (level > 1) level--;
      expToNextLevel = level * 100;
      currentExp = 0;
      streak = 0;
    } else {
      currentExp -= 20;
      if (currentExp < 0) currentExp = 0;
      streak = 0;
    }
  }

  void incrementStreak() {
    streak++;
  }
}
