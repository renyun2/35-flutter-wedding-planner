import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class VendorsPage extends ConsumerStatefulWidget {
  const VendorsPage({super.key});

  @override
  ConsumerState<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends ConsumerState<VendorsPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _categories = ['photo', 'video', 'makeup', 'host'];
  Map<String, List<Vendor>> _byCategory = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final map = <String, List<Vendor>>{};
      for (final cat in _categories) {
        map[cat] = await ref.read(weddingRepositoryProvider).getVendors(category: cat);
      }
      if (mounted) setState(() => _byCategory = map);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('四大金刚'),
        bottom: TabBar(
          controller: _tab,
          tabs: _categories.map((c) => Tab(text: vendorCategoryLabel(c))).toList(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.event), onPressed: () => context.push('/bookings')),
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/booking/create')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: _categories.map((cat) {
                final list = _byCategory[cat] ?? [];
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final v = list[i];
                    return ListTile(
                      title: Text(v.name),
                      subtitle: Text('¥${v.price.toStringAsFixed(0)} · 评分 ${v.rating}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/vendor/${v.id}'),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
