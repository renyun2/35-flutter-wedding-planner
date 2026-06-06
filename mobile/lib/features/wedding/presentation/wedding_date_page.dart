import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/repositories/wedding_repository.dart';
import '../../auth/application/auth_provider.dart';

class WeddingDatePage extends ConsumerStatefulWidget {
  const WeddingDatePage({super.key});

  @override
  ConsumerState<WeddingDatePage> createState() => _WeddingDatePageState();
}

class _WeddingDatePageState extends ConsumerState<WeddingDatePage> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wedding = ref.read(currentWeddingProvider);
      if (wedding?.weddingDate != null) {
        setState(() {
          _selected = DateTime.parse(wedding!.weddingDate!);
          _focused = _selected!;
        });
      }
    });
  }

  Future<void> _save() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    try {
      final date = DateFormat('yyyy-MM-dd').format(_selected!);
      final result = await ref.read(weddingRepositoryProvider).setWeddingDate(date);
      ref.read(authProvider.notifier).setWedding(result.wedding);
      if (!mounted) return;
      if (result.depositDeducted > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('改期扣减 Mock 定金 ¥${result.depositDeducted.toInt()}')),
        );
      }
      context.pop();
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
    final wedding = ref.watch(currentWeddingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('婚期选择')),
      body: Column(
        children: [
          if (wedding?.dateLocked == true)
            const ListTile(
              leading: Icon(Icons.lock),
              title: Text('婚期已锁定，改期将扣 Mock 定金 ¥5000'),
            ),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focused,
            selectedDayPredicate: (d) => isSameDay(_selected, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
            },
            onPageChanged: (focused) => setState(() => _focused = focused),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _loading || _selected == null ? null : _save,
              child: _loading ? const CircularProgressIndicator() : const Text('确认婚期'),
            ),
          ),
        ],
      ),
    );
  }
}
