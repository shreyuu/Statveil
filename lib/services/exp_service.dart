class ExpService {
  static int calculateExp(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 10;
      case 'Medium':
        return 25;
      case 'Hard':
        return 50;
      case 'Boss':
        return 100;
      default:
        return 0;
    }
  }
}
