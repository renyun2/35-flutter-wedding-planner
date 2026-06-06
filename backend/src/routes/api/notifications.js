const express = require('express');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const notifications = db
    .prepare(
      `SELECT * FROM notifications WHERE wedding_id = ?
       ORDER BY read ASC, created_at DESC`
    )
    .all(req.weddingId);
  res.json({ notifications });
});

router.put('/:id/read', authRequired, weddingRequired, (req, res) => {
  const result = db
    .prepare('UPDATE notifications SET read = 1 WHERE id = ? AND wedding_id = ?')
    .run(req.params.id, req.weddingId);
  if (result.changes === 0) {
    return res.status(404).json({ error: '消息不存在', code: 404 });
  }
  res.json({ ok: true });
});

module.exports = router;
