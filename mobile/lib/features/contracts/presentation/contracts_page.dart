import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/wedding_repository.dart';

class ContractsPage extends ConsumerStatefulWidget {
  const ContractsPage({super.key});

  @override
  ConsumerState<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends ConsumerState<ContractsPage> {
  List<Map<String, dynamic>> _contracts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(weddingRepositoryProvider).getContracts();
      if (mounted) setState(() => _contracts = list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showContract(Map<String, dynamic> c) {
    final url = c['pdf_url'] as String;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c['title'] as String),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('链接已复制')));
            },
            child: const Text('复制 PDF 链接'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('供应商合同')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contracts.length,
              itemBuilder: (_, i) {
                final c = _contracts[i];
                return ListTile(
                  title: Text(c['title'] as String),
                  subtitle: Text('${c['vendor_name']} · ${c['status']}'),
                  trailing: const Icon(Icons.picture_as_pdf),
                  onTap: () => _showContract(c),
                );
              },
            ),
    );
  }
}
