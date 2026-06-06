const db = require('../db');

function summarizeBudget(weddingId) {
  const wedding = db.prepare('SELECT total_budget FROM weddings WHERE id = ?').get(weddingId);
  if (!wedding) return null;

  const rows = db
    .prepare(
      `SELECT category, SUM(amount) AS total, SUM(paid_amount) AS paid,
              SUM(CASE WHEN status = 'pending' THEN amount - paid_amount ELSE 0 END) AS pending
       FROM budget_items WHERE wedding_id = ? GROUP BY category`
    )
    .all(weddingId);

  const totals = db
    .prepare(
      `SELECT COALESCE(SUM(amount), 0) AS total_spent,
              COALESCE(SUM(paid_amount), 0) AS total_paid,
              COALESCE(SUM(CASE WHEN status = 'pending' THEN amount - paid_amount ELSE 0 END), 0) AS total_pending
       FROM budget_items WHERE wedding_id = ?`
    )
    .get(weddingId);

  const totalBudget = wedding.total_budget;
  const totalSpent = totals.total_spent;
  const overBudget = totalSpent > totalBudget;

  return {
    total_budget: totalBudget,
    total_spent: totalSpent,
    total_paid: totals.total_paid,
    total_pending: totals.total_pending,
    remaining: totalBudget - totalSpent,
    over_budget: overBudget,
    by_category: rows,
  };
}

module.exports = { summarizeBudget };
