class Hunter {
  int level;
  int currentExp;
  int expToNextLevel;

  int str;
  int intStat;
  int agi;
  int vit;
  int will;

  Hunter({
    this.level = 1,
    this.currentExp = 0,
    this.expToNextLevel = 100,
    this.str = 1,
    this.intStat = 1,
    this.agi = 1,
    this.vit = 1,
    this.will = 1,
  });

  void gainExp(int exp) {
    currentExp += exp;

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
}
