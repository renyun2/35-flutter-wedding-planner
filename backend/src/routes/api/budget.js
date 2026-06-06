const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');
const { summarizeBudget } = require('../../utils/budget');

const router = express.Router();

router.get('/summary', authRequired, weddingRequired, (req, res) => {
  const summary = summarizeBudget(req.weddingId);
  res.json(summary);
});

router.get('/items', authRequired, weddingRequired, (req, res) => {
  const items = db
    .prepare('SELECT * FROM budget_items WHERE wedding_id = ? ORDER BY created_at DESC')
    .all(req.weddingId);
  res.json({ items, summary: summarizeBudget(req.weddingId) });
});

router.post('/items', authRequired, weddingRequired, (req, res) => {
  const { category, title, amount, paidAmount, status } = req.body || {};
  if (!category || !title || amount == null) {
    return res.status(400).json({ error: '请填写分类、标题和金额', code: 400 });
  }
  const id = uuid();
  const paid = paidAmount || (status === 'paid' ? amount : 0);
  const itemStatus = status || (paid >= amount ? 'paid' : 'pending');

  db.prepare(
    `INSERT INTO budget_items (id, wedding_id, category, title, amount, paid_amount, status)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  ).run(id, req.weddingId, category, title, amount, paid, itemStatus);

  res.status(201).json({
    item: db.prepare('SELECT * FROM budget_items WHERE id = ?').get(id),
    summary: summarizeBudget(req.weddingId),
  });
});

router.put('/items/:id', authRequired, weddingRequired, (req, res) => {
  const item = db
    .prepare('SELECT * FROM budget_items WHERE id = ? AND wedding_id = ?')
    .get(req.params.id, req.weddingId);
  if (!item) return res.status(404).json({ error: '预算项不存在', code: 404 });

  const { category, title, amount, paidAmount, status } = req.body || {};
  db.prepare(
    `UPDATE budget_items SET category = ?, title = ?, amount = ?, paid_amount = ?, status = ?
     WHERE id = ?`
  ).run(
    category ?? item.category,
    title ?? item.title,
    amount ?? item.amount,
    paidAmount ?? item.paid_amount,
    status ?? item.status,
    req.params.id
  );

  res.json({
    item: db.prepare('SELECT * FROM budget_items WHERE id = ?').get(req.params.id),
    summary: summarizeBudget(req.weddingId),
  });
});

router.delete('/items/:id', authRequired, weddingRequired, (req, res) => {
  const result = db
    .prepare('DELETE FROM budget_items WHERE id = ? AND wedding_id = ?')
    .run(req.params.id, req.weddingId);
  if (result.changes === 0) return res.status(404).json({ error: '预算项不存在', code: 404 });
  res.json({ ok: true, summary: summarizeBudget(req.weddingId) });
});

module.exports = router;
