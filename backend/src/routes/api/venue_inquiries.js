const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.post('/', authRequired, weddingRequired, (req, res) => {
  const { venueId, tables, message } = req.body || {};
  if (!venueId || !tables) {
    return res.status(400).json({ error: '请选择酒店和桌数', code: 400 });
  }
  const venue = db.prepare('SELECT * FROM venues WHERE id = ?').get(venueId);
  if (!venue) return res.status(404).json({ error: '酒店不存在', code: 404 });
  if (tables < venue.min_tables || tables > venue.max_tables) {
    return res.status(400).json({
      error: `桌数需在 ${venue.min_tables}-${venue.max_tables} 之间`,
      code: 400,
    });
  }

  const id = uuid();
  db.prepare(
    'INSERT INTO venue_inquiries (id, wedding_id, venue_id, tables, message) VALUES (?, ?, ?, ?, ?)'
  ).run(id, req.weddingId, venueId, tables, message || '');

  res.status(201).json({ inquiry: db.prepare('SELECT * FROM venue_inquiries WHERE id = ?').get(id) });
});

module.exports = router;
