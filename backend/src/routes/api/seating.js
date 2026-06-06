const express = require('express');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');
const { validateSeating, parseLayout } = require('../../utils/seating');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const row = db.prepare('SELECT layout_json FROM seating WHERE wedding_id = ?').get(req.weddingId);
  const guestCount = db
    .prepare("SELECT COUNT(*) AS c FROM guests WHERE wedding_id = ? AND rsvp_status != 'declined'")
    .get(req.weddingId).c;

  const layout = parseLayout(row?.layout_json);
  const validation = validateSeating(JSON.stringify(layout), guestCount);

  res.json({ layout, validation, guest_count: guestCount });
});

router.put('/', authRequired, weddingRequired, (req, res) => {
  const { layout } = req.body || {};
  if (!Array.isArray(layout)) {
    return res.status(400).json({ error: 'layout 必须为数组', code: 400 });
  }

  const guestCount = db
    .prepare("SELECT COUNT(*) AS c FROM guests WHERE wedding_id = ? AND rsvp_status != 'declined'")
    .get(req.weddingId).c;

  const validation = validateSeating(JSON.stringify(layout), guestCount);
  if (!validation.valid) {
    return res.status(400).json({ error: validation.error, code: 400, validation });
  }

  db.prepare(
    'UPDATE seating SET layout_json = ?, updated_at = datetime(\'now\') WHERE wedding_id = ?'
  ).run(JSON.stringify(layout), req.weddingId);

  res.json({ layout, validation });
});

module.exports = router;
