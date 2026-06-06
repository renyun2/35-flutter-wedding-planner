const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const tasks = db
    .prepare('SELECT * FROM tasks WHERE wedding_id = ? ORDER BY completed, due_date')
    .all(req.weddingId);
  res.json({ tasks });
});

router.post('/', authRequired, weddingRequired, (req, res) => {
  const { title, dueDate, category } = req.body || {};
  if (!title) return res.status(400).json({ error: '请填写任务标题', code: 400 });

  const id = uuid();
  db.prepare(
    'INSERT INTO tasks (id, wedding_id, title, due_date, category) VALUES (?, ?, ?, ?, ?)'
  ).run(id, req.weddingId, title, dueDate || null, category || 'general');

  res.status(201).json({ task: db.prepare('SELECT * FROM tasks WHERE id = ?').get(id) });
});

router.put('/:id', authRequired, weddingRequired, (req, res) => {
  const task = db
    .prepare('SELECT * FROM tasks WHERE id = ? AND wedding_id = ?')
    .get(req.params.id, req.weddingId);
  if (!task) return res.status(404).json({ error: '任务不存在', code: 404 });

  const { title, dueDate, completed, category } = req.body || {};
  db.prepare(
    'UPDATE tasks SET title = ?, due_date = ?, completed = ?, category = ? WHERE id = ?'
  ).run(
    title ?? task.title,
    dueDate !== undefined ? dueDate : task.due_date,
    completed !== undefined ? (completed ? 1 : 0) : task.completed,
    category ?? task.category,
    req.params.id
  );

  res.json({ task: db.prepare('SELECT * FROM tasks WHERE id = ?').get(req.params.id) });
});

router.delete('/:id', authRequired, weddingRequired, (req, res) => {
  const result = db
    .prepare('DELETE FROM tasks WHERE id = ? AND wedding_id = ?')
    .run(req.params.id, req.weddingId);
  if (result.changes === 0) return res.status(404).json({ error: '任务不存在', code: 404 });
  res.json({ ok: true });
});

module.exports = router;
