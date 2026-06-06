import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/wedding_repository.dart';

class SeatingPage extends ConsumerStatefulWidget {
  const SeatingPage({super.key});

  @override
  ConsumerState<SeatingPage> createState() => _SeatingPageState();
}

class _SeatingPageState extends ConsumerState<SeatingPage> {
  List<Map<String, dynamic>> _layout = [];
  Map<String, dynamic>? _validation;
  int _guestCount = 0;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ref.read(weddingRepositoryProvider).getSeating();
      if (mounted) {
        setState(() {
          _layout = (data['layout'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              [];
          _validation = Map<String, dynamic>.from(data['validation'] as Map? ?? {});
          _guestCount = (data['guest_count'] as num?)?.toInt() ?? 0;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(weddingRepositoryProvider).updateSeating(_layout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('座位已保存')));
        _load();
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException && e.error is ApiException
          ? (e.error as ApiException).message
          : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTable() {
    setState(() {
      _layout.add({
        'table_number': _layout.length + 1,
        'name': '新桌',
        'capacity': 10,
        'guest_ids': <String>[],
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final valid = _validation?['valid'] == true;
    return Scaffold(
      appBar: AppBar(
        title: const Text('座位图'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addTable),
          IconButton(
            icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('宾客数 $_guestCount · 总容量 ${_validation?['total_capacity'] ?? 0}'),
                Text(
                  valid ? '容量校验通过' : (_validation?['error']?.toString() ?? '容量不足'),
                  style: TextStyle(color: valid ? Colors.green : Colors.red),
                ),
                const Divider(),
                ..._layout.map((t) {
                  return Card(
                    child: ListTile(
                      title: Text('${t['name']} (${t['table_number']}号桌)'),
                      subtitle: Text('容量 ${t['capacity']} · 已分配 ${(t['guest_ids'] as List?)?.length ?? 0}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final cap = await showDialog<int>(
                            context: context,
                            builder: (_) {
                              final ctrl = TextEditingController(text: '${t['capacity']}');
                              return AlertDialog(
                                title: const Text('修改容量'),
                                content: TextField(controller: ctrl, keyboardType: TextInputType.number),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
                                    child: const Text('确定'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (cap != null) setState(() => t['capacity'] = cap);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
