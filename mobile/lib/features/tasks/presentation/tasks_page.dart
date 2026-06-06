import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  List<WeddingTask> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await ref.read(weddingRepositoryProvider).getTasks();
      if (mounted) setState(() => _tasks = tasks);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(WeddingTask task) async {
    await ref.read(weddingRepositoryProvider).toggleTask(task.id, !task.completed);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('任务清单')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return CheckboxListTile(
                  value: t.completed,
                  onChanged: (_) => _toggle(t),
                  title: Text(t.title),
                  subtitle: t.dueDate != null ? Text('截止 ${t.dueDate}') : null,
                );
              },
            ),
    );
  }
}
