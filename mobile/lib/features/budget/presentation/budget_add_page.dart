import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/wedding_repository.dart';

class BudgetAddPage extends ConsumerStatefulWidget {
  const BudgetAddPage({super.key});

  @override
  ConsumerState<BudgetAddPage> createState() => _BudgetAddPageState();
}

class _BudgetAddPageState extends ConsumerState<BudgetAddPage> {
  final _category = TextEditingController(text: '其他');
  final _title = TextEditingController();
  final _amount = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final amount = double.tryParse(_amount.text.trim());
    if (_title.text.trim().isEmpty || amount == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(weddingRepositoryProvider).addBudgetItem(
            category: _category.text.trim(),
            title: _title.text.trim(),
            amount: amount,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException && e.error is ApiException
          ? (e.error as ApiException).message
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加支出')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _category, decoration: const InputDecoration(labelText: '分类')),
          TextField(controller: _title, decoration: const InputDecoration(labelText: '标题')),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: '金额'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
