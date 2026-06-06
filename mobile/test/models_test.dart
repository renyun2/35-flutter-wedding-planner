import 'package:flutter_test/flutter_test.dart';

import 'package:wedding_planner/data/models/models.dart';

void main() {
  test('BudgetSummary fromJson detects over budget', () {
    final summary = BudgetSummary.fromJson({
      'total_budget': 100000,
      'total_spent': 120000,
      'total_paid': 80000,
      'total_pending': 40000,
      'remaining': -20000,
      'over_budget': true,
    });
    expect(summary.overBudget, isTrue);
    expect(summary.totalPending, 40000);
  });

  test('daysUntilWedding counts correctly', () {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final date = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
    expect(daysUntilWedding(date), 1);
    expect(daysUntilWedding(null), -1);
  });

  test('vendorCategoryLabel', () {
    expect(vendorCategoryLabel('photo'), '摄影');
    expect(vendorCategoryLabel('host'), '主持');
  });

  test('rsvpLabel', () {
    expect(rsvpLabel('accepted'), '确认出席');
    expect(rsvpLabel('pending'), '待回复');
  });
}
