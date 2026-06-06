const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

function randomBindCode() {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
}

router.post('/create', authRequired, (req, res) => {
  const { brideName, groomName, totalBudget } = req.body || {};
  if (!brideName || !groomName) {
    return res.status(400).json({ error: '请填写新人姓名', code: 400 });
  }
  if (req.user.wedding_id) {
    return res.status(400).json({ error: '已有婚礼档案', code: 400 });
  }

  const id = uuid();
  let bindCode = randomBindCode();
  while (db.prepare('SELECT id FROM weddings WHERE bind_code = ?').get(bindCode)) {
    bindCode = randomBindCode();
  }

  db.prepare(
    'INSERT INTO weddings (id, bride_name, groom_name, total_budget, bind_code) VALUES (?, ?, ?, ?, ?)'
  ).run(id, brideName, groomName, totalBudget || 200000, bindCode);

  db.prepare('UPDATE users SET wedding_id = ? WHERE id = ?').run(id, req.user.id);

  db.prepare('INSERT INTO seating (wedding_id, layout_json) VALUES (?, ?)').run(
    id,
    JSON.stringify([
      { table_number: 1, name: '主桌', capacity: 10, guest_ids: [] },
      { table_number: 2, name: '亲友桌A', capacity: 10, guest_ids: [] },
      { table_number: 3, name: '亲友桌B', capacity: 10, guest_ids: [] },
    ])
  );

  res.status(201).json({
    wedding: db.prepare('SELECT * FROM weddings WHERE id = ?').get(id),
    bind_code: bindCode,
  });
});

router.put('/date', authRequired, weddingRequired, (req, res) => {
  const { weddingDate } = req.body || {};
  if (!weddingDate) return res.status(400).json({ error: '请选择婚期', code: 400 });

  const wedding = db.prepare('SELECT * FROM weddings WHERE id = ?').get(req.weddingId);
  let depositDeducted = 0;

  if (wedding.date_locked && wedding.wedding_date && wedding.wedding_date !== weddingDate) {
    depositDeducted = 5000;
    db.prepare('UPDATE weddings SET deposit_paid = deposit_paid + ? WHERE id = ?').run(
      depositDeducted,
      req.weddingId
    );
  }

  db.prepare(
    'UPDATE weddings SET wedding_date = ?, date_locked = 1 WHERE id = ?'
  ).run(weddingDate, req.weddingId);

  const updated = db.prepare('SELECT * FROM weddings WHERE id = ?').get(req.weddingId);
  res.json({ wedding: updated, deposit_deducted: depositDeducted });
});

router.get('/summary', authRequired, weddingRequired, (req, res) => {
  const wedding = db.prepare('SELECT * FROM weddings WHERE id = ?').get(req.weddingId);
  const taskStats = db
    .prepare(
      'SELECT COUNT(*) AS total, SUM(completed) AS done FROM tasks WHERE wedding_id = ?'
    )
    .get(req.weddingId);
  const guestStats = db
    .prepare(
      `SELECT COUNT(*) AS total,
              SUM(CASE WHEN rsvp_status = 'accepted' THEN 1 ELSE 0 END) AS accepted
       FROM guests WHERE wedding_id = ?`
    )
    .get(req.weddingId);

  res.json({
    wedding,
    tasks: { total: taskStats.total || 0, done: taskStats.done || 0 },
    guests: { total: guestStats.total || 0, accepted: guestStats.accepted || 0 },
  });
});

module.exports = router;
