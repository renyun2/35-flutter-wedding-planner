const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const guests = db
    .prepare('SELECT * FROM guests WHERE wedding_id = ? ORDER BY table_number, name')
    .all(req.weddingId);
  res.json({ guests });
});

router.post('/', authRequired, weddingRequired, (req, res) => {
  const { name, phone, tableNumber, rsvpStatus, side } = req.body || {};
  if (!name) return res.status(400).json({ error: '请填写宾客姓名', code: 400 });

  const id = uuid();
  db.prepare(
    `INSERT INTO guests (id, wedding_id, name, phone, table_number, rsvp_status, side)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  ).run(
    id,
    req.weddingId,
    name,
    phone || '',
    tableNumber ?? null,
    rsvpStatus || 'pending',
    side || 'bride'
  );

  res.status(201).json({ guest: db.prepare('SELECT * FROM guests WHERE id = ?').get(id) });
});

router.put('/:id', authRequired, weddingRequired, (req, res) => {
  const guest = db
    .prepare('SELECT * FROM guests WHERE id = ? AND wedding_id = ?')
    .get(req.params.id, req.weddingId);
  if (!guest) return res.status(404).json({ error: '宾客不存在', code: 404 });

  const { name, phone, tableNumber, rsvpStatus, side } = req.body || {};
  db.prepare(
    `UPDATE guests SET name = ?, phone = ?, table_number = ?, rsvp_status = ?, side = ?
     WHERE id = ?`
  ).run(
    name ?? guest.name,
    phone ?? guest.phone,
    tableNumber !== undefined ? tableNumber : guest.table_number,
    rsvpStatus ?? guest.rsvp_status,
    side ?? guest.side,
    req.params.id
  );

  res.json({ guest: db.prepare('SELECT * FROM guests WHERE id = ?').get(req.params.id) });
});

router.delete('/:id', authRequired, weddingRequired, (req, res) => {
  const result = db
    .prepare('DELETE FROM guests WHERE id = ? AND wedding_id = ?')
    .run(req.params.id, req.weddingId);
  if (result.changes === 0) return res.status(404).json({ error: '宾客不存在', code: 404 });
  res.json({ ok: true });
});

module.exports = router;
