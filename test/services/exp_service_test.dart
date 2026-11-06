import 'package:flutter_test/flutter_test.dart';
import 'package:statveil/features/quests/quest_model.dart';
import 'package:statveil/services/exp_service.dart';

void main() {
  test('harder quests award more exp', () {
    expect(Difficulty.values.map(ExpService.expForDifficulty).toList(), [
      10,
      25,
      50,
      100,
    ]);
  });
}
