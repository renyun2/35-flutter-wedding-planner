import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class VenueInquiryPage extends ConsumerStatefulWidget {
  const VenueInquiryPage({super.key, required this.venueId});
  final String venueId;

  @override
  ConsumerState<VenueInquiryPage> createState() => _VenueInquiryPageState();
}

class _VenueInquiryPageState extends ConsumerState<VenueInquiryPage> {
  Venue? _venue;
  final _tables = TextEditingController(text: '20');
  final _message = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    ref.read(weddingRepositoryProvider).getVenue(widget.venueId).then((v) {
      if (mounted) setState(() => _venue = v);
    });
  }

  Future<void> _submit() async {
    final tables = int.tryParse(_tables.text.trim());
    if (tables == null || _venue == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(weddingRepositoryProvider).createVenueInquiry(
            venueId: widget.venueId,
            tables: tables,
            message: _message.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('询价已提交')));
        context.pop();
      }
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
    final v = _venue;
    return Scaffold(
      appBar: AppBar(title: const Text('酒店询价')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(v?.name ?? '加载中...'),
          if (v != null) Text('可选桌数 ${v.minTables}-${v.maxTables}'),
          TextField(
            controller: _tables,
            decoration: const InputDecoration(labelText: '预订桌数'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _message,
            decoration: const InputDecoration(labelText: '备注'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: const Text('提交询价'),
          ),
        ],
      ),
    );
  }
}
