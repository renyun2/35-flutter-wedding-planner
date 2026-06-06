import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/wedding_repository.dart';
import '../../auth/application/auth_provider.dart';

class WeddingCreatePage extends ConsumerStatefulWidget {
  const WeddingCreatePage({super.key});

  @override
  ConsumerState<WeddingCreatePage> createState() => _WeddingCreatePageState();
}

class _WeddingCreatePageState extends ConsumerState<WeddingCreatePage> {
  final _bride = TextEditingController();
  final _groom = TextEditingController();
  final _bindCode = TextEditingController();
  bool _loading = false;
  bool _bindMode = false;

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(weddingRepositoryProvider);
      final result = await repo.createWedding(
        brideName: _bride.text.trim(),
        groomName: _groom.text.trim(),
      );
      ref.read(authProvider.notifier).setWedding(result.wedding);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('创建成功'),
          content: Text('绑定码：${result.bindCode}\n分享给伴侣即可协作'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
          ],
        ),
      );
      context.go('/home');
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

  Future<void> _bind() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(weddingRepositoryProvider);
      final wedding = await repo.bindWedding(_bindCode.text.trim());
      ref.read(authProvider.notifier).setWedding(wedding);
      if (!mounted) return;
      context.go('/home');
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
      appBar: AppBar(title: const Text('创建婚礼')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('新建')),
              ButtonSegment(value: true, label: Text('绑定')),
            ],
            selected: {_bindMode},
            onSelectionChanged: (s) => setState(() => _bindMode = s.first),
          ),
          const SizedBox(height: 24),
          if (!_bindMode) ...[
            TextField(controller: _bride, decoration: const InputDecoration(labelText: '新娘姓名')),
            const SizedBox(height: 12),
            TextField(controller: _groom, decoration: const InputDecoration(labelText: '新郎姓名')),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _create,
              child: const Text('创建婚礼档案'),
            ),
          ] else ...[
            TextField(controller: _bindCode, decoration: const InputDecoration(labelText: '绑定码')),
            const SizedBox(height: 8),
            const Text('演示绑定码：DEMO01'),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _bind,
              child: const Text('绑定伴侣婚礼'),
            ),
          ],
        ],
      ),
    );
  }
}
