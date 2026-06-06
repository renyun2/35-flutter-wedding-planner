import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class GuestsPage extends ConsumerStatefulWidget {
  const GuestsPage({super.key});

  @override
  ConsumerState<GuestsPage> createState() => _GuestsPageState();
}

class _GuestsPageState extends ConsumerState<GuestsPage> {
  List<Guest> _guests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final guests = await ref.read(weddingRepositoryProvider).getGuests();
      if (mounted) setState(() => _guests = guests);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('宾客名单'),
        actions: [
          IconButton(icon: const Icon(Icons.event_seat), onPressed: () => context.push('/seating')),
          IconButton(icon: const Icon(Icons.person_add), onPressed: () => context.push('/guest/create')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _guests.length,
                itemBuilder: (_, i) {
                  final g = _guests[i];
                  return ListTile(
                    title: Text(g.name),
                    subtitle: Text('${g.side == 'bride' ? '女方' : '男方'} · ${rsvpLabel(g.rsvpStatus)}'),
                    trailing: Text(g.tableNumber != null ? '${g.tableNumber}桌' : '-'),
                  );
                },
              ),
            ),
    );
  }
}
