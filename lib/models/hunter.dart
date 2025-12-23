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
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  void gainExp(int exp, String stat) {
    currentExp += exp;

    switch (stat) {
      case 'STR':
        str++;
        break;
      case 'INT':
        intStat++;
        break;
      case 'AGI':
        agi++;
        break;
      case 'VIT':
        vit++;
        break;
      case 'WILL':
        will++;
        break;
    }

    if (currentExp >= expToNextLevel) {
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
