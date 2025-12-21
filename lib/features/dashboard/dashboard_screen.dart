import 'package:flutter/material.dart';
import '../../models/hunter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Hunter hunter = Hunter();

  void _completeQuest() {
    setState(() {
      hunter.gainExp(25); // Medium task simulation
    });
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

            const SizedBox(height: 16),
            Text('EXP: ${hunter.currentExp}/${hunter.expToNextLevel}'),

            const SizedBox(height: 24),
            Text('Stats', style: Theme.of(context).textTheme.titleLarge),

            Text('STR: ${hunter.str}'),
            Text('INT: ${hunter.intStat}'),
            Text('AGI: ${hunter.agi}'),
            Text('VIT: ${hunter.vit}'),
            Text('WILL: ${hunter.will}'),

            const Spacer(),

            ElevatedButton(
              onPressed: _completeQuest,
              child: const Text('Complete Quest (+25 EXP)'),
            ),
          ],
        ),
      ),
    );
  }
}
