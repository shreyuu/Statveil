import 'package:flutter/material.dart';
import 'package:statveil/services/auth_service.dart';
import '../../models/hunter.dart';
import '../../services/exp_service.dart';
import '../quests/quest_model.dart';
import '../quests/quest_service.dart';
import '../../core/utils/daily_reset.dart';
import 'package:statveil/services/hunter_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Hunter hunter = Hunter();
  late List<Quest> dailyQuests;

  @override
  void initState() {
    super.initState();
    AuthService.signInAnon();
    dailyQuests = QuestService.getDailyQuests();

    if (DailyReset.shouldReset(hunter.lastUpdated)) {
      DailyReset.resetDay(hunter: hunter, dailyQuests: dailyQuests);
    }
  }

  void completeQuest(Quest quest) {
    if (quest.completed) return;

    final exp = ExpService.expForDifficulty(quest.difficulty);

    setState(() {
      quest.completed = true;
      hunter.gainExp(exp, quest.stat);
    });
    HunterService.saveHunter(hunter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statveil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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

                  return Card(
                    child: ListTile(
                      title: Text(quest.title),
                      subtitle: Text(
                        '${quest.stat} • ${quest.difficulty.name.toUpperCase()}',
                      ),
                      trailing: quest.completed
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              onPressed: () => completeQuest(quest),
                              child: const Text('Complete'),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
