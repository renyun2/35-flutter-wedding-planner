import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class BookingCreatePage extends ConsumerStatefulWidget {
  const BookingCreatePage({super.key, this.vendorId});
  final String? vendorId;

  @override
  ConsumerState<BookingCreatePage> createState() => _BookingCreatePageState();
}

class _BookingCreatePageState extends ConsumerState<BookingCreatePage> {
  List<Vendor> _vendors = [];
  String? _selectedVendorId;
  String? _selectedDate;
  List<Map<String, dynamic>> _availability = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedVendorId = widget.vendorId;
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final vendors = await ref.read(weddingRepositoryProvider).getVendors();
    if (mounted) {
      setState(() => _vendors = vendors);
      if (_selectedVendorId != null) _loadAvailability(_selectedVendorId!);
    }
  }

  Future<void> _loadAvailability(String vendorId) async {
    final data = await ref.read(weddingRepositoryProvider).getVendorDetail(vendorId);
    if (mounted) {
      setState(() {
        _availability = (data['availability'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .where((a) => a['available'] == 1)
                .toList() ??
            [];
        _selectedDate = _availability.isNotEmpty ? _availability.first['date'] as String? : null;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedVendorId == null || _selectedDate == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(weddingRepositoryProvider).createBooking(
            vendorId: _selectedVendorId!,
            bookingDate: _selectedDate!,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('预约成功')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('预约档期')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _selectedVendorId,
            decoration: const InputDecoration(labelText: '供应商'),
            items: _vendors
                .map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text('${vendorCategoryLabel(v.category)} - ${v.name}'),
                    ))
                .toList(),
            onChanged: (id) {
              setState(() => _selectedVendorId = id);
              if (id != null) _loadAvailability(id);
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedDate,
            decoration: const InputDecoration(labelText: '档期'),
            items: _availability
                .map((a) => DropdownMenuItem(
                      value: a['date'] as String,
                      child: Text(a['date'] as String),
                    ))
                .toList(),
            onChanged: (d) => setState(() => _selectedDate = d),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: const Text('确认预约'),
          ),
        ],
      ),
    );
  }
}
