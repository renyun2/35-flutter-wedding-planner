import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class BudgetItemsPage extends ConsumerStatefulWidget {
  const BudgetItemsPage({super.key});

  @override
  ConsumerState<BudgetItemsPage> createState() => _BudgetItemsPageState();
}

class _BudgetItemsPageState extends ConsumerState<BudgetItemsPage> {
  List<BudgetItem> _items = [];
  BudgetSummary? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await ref.read(weddingRepositoryProvider).getBudgetItems();
      if (mounted) {
        setState(() {
          _items = result.items;
          _summary = result.summary;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预算明细'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/budget/add')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('${item.category} · ${item.status == 'paid' ? '已付' : '待付'}'),
                  trailing: Text('¥${item.amount.toStringAsFixed(0)}'),
                );
              },
            ),
    );
  }
}
