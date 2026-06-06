import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class VenueDetailPage extends ConsumerStatefulWidget {
  const VenueDetailPage({super.key, required this.venueId});
  final String venueId;

  @override
  ConsumerState<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends ConsumerState<VenueDetailPage> {
  Venue? _venue;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final venue = await ref.read(weddingRepositoryProvider).getVenue(widget.venueId);
    if (mounted) setState(() {
      _venue = venue;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = _venue;
    return Scaffold(
      appBar: AppBar(title: Text(v?.name ?? '酒店详情')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : v == null
              ? const Center(child: Text('未找到酒店'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (v.imageUrl.isNotEmpty) Image.network(v.imageUrl, height: 180, fit: BoxFit.cover),
                    Text(v.name, style: Theme.of(context).textTheme.headlineSmall),
                    Text(v.address),
                    Text('${v.district} · 距城区 Mock ${v.distanceKm} km'),
                    Text('桌数范围 ${v.minTables}-${v.maxTables} 桌'),
                    Text('¥${v.pricePerTable.toStringAsFixed(0)}/桌'),
                    const SizedBox(height: 8),
                    Text(v.description),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.push('/venue/${v.id}/inquiry'),
                      child: const Text('发起询价'),
                    ),
                  ],
                ),
    );
  }
}
