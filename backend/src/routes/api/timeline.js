const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const items = db
    .prepare('SELECT * FROM timeline_items WHERE wedding_id = ? ORDER BY time_minutes')
    .all(req.weddingId);
  res.json({ items });
});

router.post('/', authRequired, weddingRequired, (req, res) => {
  const { timeMinutes, title, note } = req.body || {};
  if (timeMinutes == null || !title) {
    return res.status(400).json({ error: '请填写时间和标题', code: 400 });
  }

  const id = uuid();
  db.prepare(
    'INSERT INTO timeline_items (id, wedding_id, time_minutes, title, note) VALUES (?, ?, ?, ?, ?)'
  ).run(id, req.weddingId, timeMinutes, title, note || '');

  res.status(201).json({ item: db.prepare('SELECT * FROM timeline_items WHERE id = ?').get(id) });
});

router.put('/:id', authRequired, weddingRequired, (req, res) => {
  const item = db
    .prepare('SELECT * FROM timeline_items WHERE id = ? AND wedding_id = ?')
    .get(req.params.id, req.weddingId);
  if (!item) return res.status(404).json({ error: '流程项不存在', code: 404 });

  const { timeMinutes, title, note } = req.body || {};
  db.prepare(
    'UPDATE timeline_items SET time_minutes = ?, title = ?, note = ? WHERE id = ?'
  ).run(
    timeMinutes ?? item.time_minutes,
    title ?? item.title,
    note ?? item.note,
    req.params.id
  );

  res.json({ item: db.prepare('SELECT * FROM timeline_items WHERE id = ?').get(req.params.id) });
});

router.delete('/:id', authRequired, weddingRequired, (req, res) => {
  const result = db
    .prepare('DELETE FROM timeline_items WHERE id = ? AND wedding_id = ?')
    .run(req.params.id, req.weddingId);
  if (result.changes === 0) return res.status(404).json({ error: '流程项不存在', code: 404 });
  res.json({ ok: true });
});

module.exports = router;
