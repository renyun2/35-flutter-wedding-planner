import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/wedding_repository.dart';

class GuestCreatePage extends ConsumerStatefulWidget {
  const GuestCreatePage({super.key});

  @override
  ConsumerState<GuestCreatePage> createState() => _GuestCreatePageState();
}

class _GuestCreatePageState extends ConsumerState<GuestCreatePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _side = 'bride';
  bool _loading = false;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(weddingRepositoryProvider).addGuest(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            side: _side,
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
      appBar: AppBar(title: const Text('添加宾客')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: '姓名')),
          TextField(controller: _phone, decoration: const InputDecoration(labelText: '手机')),
          DropdownButtonFormField<String>(
            value: _side,
            decoration: const InputDecoration(labelText: '归属'),
            items: const [
              DropdownMenuItem(value: 'bride', child: Text('女方')),
              DropdownMenuItem(value: 'groom', child: Text('男方')),
            ],
            onChanged: (v) => setState(() => _side = v ?? 'bride'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _loading ? null : _submit, child: const Text('保存')),
        ],
      ),
    );
  }
}
