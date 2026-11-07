import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/utils/daily_reset.dart';
import '../../models/hunter.dart';
import '../../services/exp_service.dart';
import '../../services/hunter_service.dart';
import '../quests/add_quest_dialog.dart';
import '../quests/quest_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.loadHunter = HunterService.loadHunter,
    this.saveHunter = HunterService.saveHunter,
  });

  // Injectable so widget tests can run without Firebase.
  final Future<Hunter> Function() loadHunter;
  final Future<void> Function(Hunter) saveHunter;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Hunter? hunter;
  Object? loadError;
  late final AppLifecycleListener _lifecycle;
  // Catches midnight while the app stays open; resume covers it coming back from the background.
  late final Timer _dayCheck;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _checkDayChange);
    _dayCheck = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkDayChange(),
    );
    _load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _dayCheck.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loaded = await widget.loadHunter();
      final rolled = DailyReset.rollOver(loaded, loaded.quests);
      if (!mounted) return;
      setState(() => hunter = loaded);
      if (rolled) _save(loaded);
    } catch (e, stack) {
      debugPrint('Failed to load hunter: $e\n$stack');
      if (mounted) setState(() => loadError = e);
    }
  }

  void _retry() {
    setState(() => loadError = null);
    _load();
  }

  void _checkDayChange() {
    final hunter = this.hunter;
    if (hunter == null) return;
    var rolled = false;
    setState(() {
      rolled = DailyReset.rollOver(hunter, hunter.quests);
    });
    if (rolled) _save(hunter);
  }

  void completeQuest(Hunter hunter, Quest quest) {
    final exp = ExpService.expForDifficulty(quest.difficulty);
    var changed = false;
    setState(() {
      final rolled = DailyReset.rollOver(hunter, hunter.quests);
      final awarded = hunter.completeQuest(
        quest.id,
        exp: exp,
        stat: quest.stat,
      );
      changed = rolled || awarded;
    });
    if (changed) _save(hunter);
  }

  Future<void> _addQuest(Hunter hunter) async {
    final quest = await showAddQuestDialog(context);
    if (quest == null || !mounted) return;
    setState(() => hunter.quests.add(quest));
    _save(hunter);
  }

  Future<void> _deleteQuest(Hunter hunter, Quest quest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete quest?'),
        content: Text(quest.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => hunter.quests.removeWhere((q) => q.id == quest.id));
    _save(hunter);
  }

  // Not awaited by callers: offline, Firestore only completes the write once the server confirms it.
  Future<void> _save(Hunter hunter) async {
    try {
      await widget.saveHunter(hunter);
    } catch (e, stack) {
      debugPrint('Failed to save hunter: $e\n$stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't save your progress. Check your connection."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hunter = this.hunter;
    return Scaffold(
      appBar: AppBar(title: const Text('Statveil')),
      body: Padding(padding: const EdgeInsets.all(16), child: _body(context)),
      floatingActionButton: hunter == null
          ? null
          : FloatingActionButton(
              tooltip: 'Add quest',
              onPressed: () => _addQuest(hunter),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _body(BuildContext context) {
    final hunter = this.hunter;
    if (hunter != null) return _dashboard(context, hunter);

    if (loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Couldn't load your progress."),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _retry, child: const Text('Retry')),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _dashboard(BuildContext context, Hunter hunter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Level ${hunter.level}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),

        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: hunter.currentExp / hunter.expToNextLevel,
        ),

        const SizedBox(height: 12),
        Text('🔥 Streak: ${hunter.streak} days'),

        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final stat in Stat.values)
              Chip(label: Text('${stat.label} ${hunter.statValue(stat)}')),
          ],
        ),

        const SizedBox(height: 24),
        Text('Daily Quests', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 8),

        Expanded(
          child: hunter.quests.isEmpty
              ? const Center(child: Text('No quests yet. Tap + to add one.'))
              : _questList(hunter),
        ),
      ],
    );
  }

  Widget _questList(Hunter hunter) {
    return ListView.builder(
      // Room for the add button so it never covers the last quest.
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: hunter.quests.length,
      itemBuilder: (context, index) {
        final quest = hunter.quests[index];
        final done = hunter.completedQuestIds.contains(quest.id);

        return Card(
          child: ListTile(
            leading: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete quest',
              onPressed: () => _deleteQuest(hunter, quest),
            ),
            title: Text(quest.title),
            subtitle: Text(
              '${quest.stat.label} • ${quest.difficulty.name.toUpperCase()}',
            ),
            trailing: done
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                    semanticLabel: 'Completed',
                  )
                : ElevatedButton(
                    onPressed: () => completeQuest(hunter, quest),
                    child: const Text('Complete'),
                  ),
          ),
        );
      },
    );
  }
}
