import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statveil/features/dashboard/dashboard_screen.dart';
import 'package:statveil/models/hunter.dart';

void main() {
  // Snapshot of every hunter the screen saved, in order.
  late List<Map<String, dynamic>> saved;

  setUp(() => saved = []);

  Widget app(
    Future<Hunter> Function() load, {
    Future<void> Function(Hunter)? save,
  }) => MaterialApp(
    home: DashboardScreen(
      loadHunter: load,
      saveHunter: save ?? (hunter) async => saved.add(hunter.toMap()),
    ),
  );

  Future<void> openDashboard(WidgetTester tester, Hunter hunter) async {
    await tester.pumpWidget(app(() async => hunter));
    // Settle so the add button has finished scaling in and can be tapped.
    await tester.pumpAndSettle();
  }

  testWidgets('shows a spinner, then level, stats and quests', (tester) async {
    final loading = Completer<Hunter>();
    await tester.pumpWidget(app(() => loading.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    loading.complete(
      Hunter(
        level: 3,
        expToNextLevel: 300,
        str: 2,
        intStat: 4,
        agi: 1,
        vit: 5,
        will: 6,
      ),
    );
    await tester.pump();

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('STR 2'), findsOneWidget);
    expect(find.text('INT 4'), findsOneWidget);
    expect(find.text('AGI 1'), findsOneWidget);
    expect(find.text('VIT 5'), findsOneWidget);
    expect(find.text('WILL 6'), findsOneWidget);
    expect(find.text('Code for 1 hour'), findsOneWidget);
  });

  testWidgets('a failed load offers Retry, which loads the dashboard', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      app(() async {
        attempts++;
        if (attempts == 1) throw Exception('offline');
        return Hunter();
      }),
    );
    await tester.pump();

    expect(find.text("Couldn't load your progress."), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Level 1'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('completing a quest awards exp, marks it done and saves once', (
    tester,
  ) async {
    await openDashboard(tester, Hunter());

    // First quest: "Code for 1 hour", MEDIUM (25 exp), INT.
    await tester.tap(find.text('Complete').first);
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Complete'), findsNWidgets(2));
    expect(find.text('INT 2'), findsOneWidget);
    expect(saved, hasLength(1));
    expect(saved.single['currentExp'], 25);
    expect(saved.single['completedQuestIds'], ['q1']);
  });

  testWidgets('a failed save tells the user', (tester) async {
    await tester.pumpWidget(
      app(() async => Hunter(), save: (_) async => throw Exception('offline')),
    );
    await tester.pump();

    await tester.tap(find.text('Complete').first);
    await tester.pumpAndSettle();

    expect(
      find.text("Couldn't save your progress. Check your connection."),
      findsOneWidget,
    );
  });

  group('adding a quest', () {
    testWidgets('shows the new quest and saves it', (tester) async {
      await openDashboard(tester, Hunter());

      await tester.tap(find.byTooltip('Add quest'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  Read 20 pages  ');
      await tester.tap(find.text('EASY (+10 EXP)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BOSS (+100 EXP)').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('STR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WILL').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Read 20 pages'), findsOneWidget);
      expect(find.text('WILL • BOSS'), findsOneWidget);
      expect(saved, hasLength(1));
      final quest = (saved.single['quests'] as List).last as Map;
      expect(quest['title'], 'Read 20 pages');
      expect(quest['difficulty'], 'boss');
      expect(quest['stat'], 'will');
    });

    testWidgets('rejects a blank title', (tester) async {
      await openDashboard(tester, Hunter());

      await tester.tap(find.byTooltip('Add quest'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a title'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(saved, isEmpty);
    });
  });

  group('deleting a quest', () {
    testWidgets('removes it and saves after confirming', (tester) async {
      await openDashboard(tester, Hunter());

      await tester.tap(find.byTooltip('Delete quest').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Code for 1 hour'), findsNothing);
      expect(saved, hasLength(1));
      expect((saved.single['quests'] as List).map((q) => (q as Map)['id']), [
        'q2',
        'q3',
      ]);
    });

    testWidgets('keeps it when cancelled', (tester) async {
      await openDashboard(tester, Hunter());

      await tester.tap(find.byTooltip('Delete quest').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Code for 1 hour'), findsOneWidget);
      expect(saved, isEmpty);
    });
  });

  testWidgets('with no quests, says how to add one', (tester) async {
    await openDashboard(tester, Hunter(quests: []));

    expect(find.text('No quests yet. Tap + to add one.'), findsOneWidget);
  });

  testWidgets('notices a new day while the app stays open', (tester) async {
    final hunter = Hunter(completedQuestIds: {'q1'});
    await openDashboard(tester, hunter);
    expect(find.text('Complete'), findsNWidgets(2));

    // Midnight passes with the dashboard open.
    hunter.lastUpdated = DateTime.now().subtract(const Duration(days: 1));
    await tester.pump(const Duration(minutes: 1));

    expect(find.text('Complete'), findsNWidgets(3));
    expect(saved, hasLength(1));
  });
}
