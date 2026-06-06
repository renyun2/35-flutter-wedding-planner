import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class VenuesPage extends ConsumerStatefulWidget {
  const VenuesPage({super.key});

  @override
  ConsumerState<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends ConsumerState<VenuesPage> {
  List<Venue> _venues = [];
  bool _loading = true;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final venues = await ref.read(weddingRepositoryProvider).getVenues(maxPrice: _maxPrice);
      if (mounted) setState(() => _venues = venues);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('酒店列表'),
        actions: [
          PopupMenuButton<double?>(
            onSelected: (v) {
              _maxPrice = v;
              _load();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('全部价位')),
              PopupMenuItem(value: 4000, child: Text('≤4000/桌')),
              PopupMenuItem(value: 5000, child: Text('≤5000/桌')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _venues.length,
              itemBuilder: (_, i) {
                final v = _venues[i];
                return ListTile(
                  leading: v.imageUrl.isNotEmpty
                      ? Image.network(v.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                      : const Icon(Icons.hotel),
                  title: Text(v.name),
                  subtitle: Text('${v.district} · ${v.minTables}-${v.maxTables}桌 · 距城区${v.distanceKm}km'),
                  trailing: Text('¥${v.pricePerTable.toStringAsFixed(0)}/桌'),
                  onTap: () => context.push('/venue/${v.id}'),
                );
              },
            ),
    );
  }
}
