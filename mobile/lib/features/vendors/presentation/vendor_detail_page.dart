import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class VendorDetailPage extends ConsumerStatefulWidget {
  const VendorDetailPage({super.key, required this.vendorId});
  final String vendorId;

  @override
  ConsumerState<VendorDetailPage> createState() => _VendorDetailPageState();
}

class _VendorDetailPageState extends ConsumerState<VendorDetailPage> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(weddingRepositoryProvider).getVendorDetail(widget.vendorId);
    if (mounted) setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final vendor = Vendor.fromJson(Map<String, dynamic>.from(_data!['vendor'] as Map));
    final availability = (_data!['availability'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(vendor.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(vendorCategoryLabel(vendor.category)),
          Text('¥${vendor.price.toStringAsFixed(0)}'),
          Text('评分 ${vendor.rating}'),
          Text(vendor.description),
          const Divider(),
          const Text('可预约档期'),
          ...availability.map((a) {
            final map = Map<String, dynamic>.from(a as Map);
            final available = map['available'] == 1;
            return ListTile(
              dense: true,
              title: Text(map['date'] as String),
              trailing: Text(available ? '可约' : '已满'),
            );
          }),
          FilledButton(
            onPressed: () => context.push('/booking/create?vendorId=${vendor.id}'),
            child: const Text('预约档期'),
          ),
        ],
      ),
    );
  }
}
