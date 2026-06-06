const express = require('express');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const contracts = db
    .prepare('SELECT * FROM contracts WHERE wedding_id = ? ORDER BY title')
    .all(req.weddingId);
  res.json({ contracts });
});

module.exports = router;
