import 'package:flutter/material.dart';
import '../../core/utils/daily_reset.dart';
import '../../models/hunter.dart';
import '../../services/exp_service.dart';
import '../../services/hunter_service.dart';
import '../quests/quest_model.dart';
import '../quests/quest_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Quest> dailyQuests = QuestService.getDailyQuests();
  Hunter? hunter;
  Object? loadError;
  // shortcut: a day change is only noticed on load, resume or a tap; add a midnight Timer if the app sits in the foreground overnight.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    _load();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loaded = await HunterService.loadHunter();
      final rolled = DailyReset.rollOver(loaded, dailyQuests);
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

  void _onResume() {
    final hunter = this.hunter;
    if (hunter == null) return;
    var rolled = false;
    setState(() {
      rolled = DailyReset.rollOver(hunter, dailyQuests);
    });
    if (rolled) _save(hunter);
  }

  void completeQuest(Hunter hunter, Quest quest) {
    final exp = ExpService.expForDifficulty(quest.difficulty);
    var changed = false;
    setState(() {
      final rolled = DailyReset.rollOver(hunter, dailyQuests);
      final awarded = hunter.completeQuest(
        quest.id,
        exp: exp,
        stat: quest.stat,
      );
      changed = rolled || awarded;
    });
    if (changed) _save(hunter);
  }

  // Not awaited by callers: offline, Firestore only completes the write once the server confirms it.
  Future<void> _save(Hunter hunter) async {
    try {
      await HunterService.saveHunter(hunter);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Statveil')),
      body: Padding(padding: const EdgeInsets.all(16), child: _body(context)),
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

        const SizedBox(height: 24),
        Text('Daily Quests', style: Theme.of(context).textTheme.titleLarge),

        const SizedBox(height: 8),

        Expanded(
          child: ListView.builder(
            itemCount: dailyQuests.length,
            itemBuilder: (context, index) {
              final quest = dailyQuests[index];
              final done = hunter.completedQuestIds.contains(quest.id);

              return Card(
                child: ListTile(
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
          ),
        ),
      ],
    );
  }
}
