import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/wedding_repository.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ref.read(weddingRepositoryProvider).getNotifications();
      if (mounted) setState(() => _items = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await ref.read(weddingRepositoryProvider).markNotificationRead(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('消息')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final n = _items[i];
                final read = n['read'] == 1;
                return ListTile(
                  leading: Icon(read ? Icons.mark_email_read : Icons.mark_email_unread),
                  title: Text(n['title'] as String, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n['body'] as String? ?? ''),
                  onTap: read ? null : () => _markRead(n['id'] as String),
                );
              },
            ),
    );
  }
}
