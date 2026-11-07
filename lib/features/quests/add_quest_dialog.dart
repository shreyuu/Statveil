import 'package:flutter/material.dart';
import '../../models/hunter.dart';
import '../../services/exp_service.dart';
import 'quest_model.dart';

const _maxTitleLength = 60;

/// Asks for a new daily quest; null if the user cancels.
Future<Quest?> showAddQuestDialog(BuildContext context) => showDialog<Quest>(
  context: context,
  builder: (_) => const _AddQuestDialog(),
);

class _AddQuestDialog extends StatefulWidget {
  const _AddQuestDialog();

  @override
  State<_AddQuestDialog> createState() => _AddQuestDialogState();
}

class _AddQuestDialogState extends State<_AddQuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  var _difficulty = Difficulty.easy;
  var _stat = Stat.str;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Quest(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        type: QuestType.daily,
        difficulty: _difficulty,
        stat: _stat,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New quest'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              maxLength: _maxTitleLength,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'Enter a title' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            DropdownButtonFormField<Difficulty>(
              initialValue: _difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: [
                for (final difficulty in Difficulty.values)
                  DropdownMenuItem(
                    value: difficulty,
                    child: Text(
                      '${difficulty.name.toUpperCase()} '
                      '(+${ExpService.expForDifficulty(difficulty)} EXP)',
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _difficulty = value!),
            ),
            DropdownButtonFormField<Stat>(
              initialValue: _stat,
              decoration: const InputDecoration(labelText: 'Stat'),
              items: [
                for (final stat in Stat.values)
                  DropdownMenuItem(value: stat, child: Text(stat.label)),
              ],
              onChanged: (value) => setState(() => _stat = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
