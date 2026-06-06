const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (_req, res) => {
  const items = db.prepare('SELECT * FROM inspirations ORDER BY title').all();
  const parsed = items.map((i) => ({
    ...i,
    tags: JSON.parse(i.tags_json || '[]'),
  }));
  res.json({ inspirations: parsed });
});

module.exports = router;
