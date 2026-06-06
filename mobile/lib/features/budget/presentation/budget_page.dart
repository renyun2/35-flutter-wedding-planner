import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
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
      final summary = await ref.read(weddingRepositoryProvider).getBudgetSummary();
      if (mounted) setState(() => _summary = summary);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _summary;
    final overColor = s?.overBudget == true ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('预算总览'),
        actions: [
          IconButton(icon: const Icon(Icons.list), onPressed: () => context.push('/budget/items')),
          IconButton(icon: const Icon(Icons.add), onPressed: () => context.push('/budget/add')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : s == null
              ? const Center(child: Text('暂无数据'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: s.totalPaid,
                                title: '已付',
                                color: Colors.blue,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: s.totalPending,
                                title: '待付',
                                color: Colors.orange,
                                radius: 50,
                              ),
                              PieChartSectionData(
                                value: s.remaining > 0 ? s.remaining : 0,
                                title: '剩余',
                                color: Colors.grey,
                                radius: 50,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text('总预算 ¥${s.totalBudget.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleLarge),
                      Text('已付 ¥${s.totalPaid.toStringAsFixed(0)} | 待付 ¥${s.totalPending.toStringAsFixed(0)}'),
                      Text(
                        s.overBudget ? '已超支 ¥${(-s.remaining).toStringAsFixed(0)}' : '剩余 ¥${s.remaining.toStringAsFixed(0)}',
                        style: TextStyle(color: overColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (s.totalSpent / s.totalBudget).clamp(0, 1),
                        color: overColor,
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
    );
  }
}
