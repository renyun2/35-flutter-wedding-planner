import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';
import '../../auth/application/auth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(weddingRepositoryProvider).getHomeSummary();
      if (mounted) setState(() => _summary = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wedding = ref.watch(currentWeddingProvider);
    final days = daysUntilWedding(wedding?.weddingDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(wedding != null ? '${wedding.brideName} & ${wedding.groomName}' : '筹备首页'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () => context.push('/messages')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(days >= 0 ? '距离婚礼还有 $days 天' : '请先选择婚期'),
                      subtitle: Text(wedding?.weddingDate ?? '未设置'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/wedding/date'),
                    ),
                  ),
                  if (_summary != null) ...[
                    Card(
                      child: ListTile(
                        title: const Text('任务进度'),
                        subtitle: Text(
                          '已完成 ${_summary!['tasks']['done']} / ${_summary!['tasks']['total']}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/tasks'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('宾客 RSVP'),
                        subtitle: Text(
                          '确认 ${_summary!['guests']['accepted']} / ${_summary!['guests']['total']}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/seating'),
                      ),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.hotel),
                    title: const Text('婚宴酒店'),
                    onTap: () => context.push('/venues'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('我的预约'),
                    onTap: () => context.push('/bookings'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule),
                    title: const Text('当天流程'),
                    onTap: () => context.push('/timeline'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('灵感案例'),
                    onTap: () => context.push('/inspirations'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('供应商合同'),
                    onTap: () => context.push('/contracts'),
                  ),
                ],
              ),
            ),
    );
  }
}
