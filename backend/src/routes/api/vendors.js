const express = require('express');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const { category } = req.query;
  let vendors;
  if (category) {
    vendors = db
      .prepare('SELECT * FROM vendors WHERE category = ? ORDER BY rating DESC')
      .all(category);
  } else {
    vendors = db.prepare('SELECT * FROM vendors ORDER BY category, rating DESC').all();
  }
  res.json({ vendors });
});

router.get('/:id', authRequired, (req, res) => {
  const vendor = db.prepare('SELECT * FROM vendors WHERE id = ?').get(req.params.id);
  if (!vendor) return res.status(404).json({ error: '供应商不存在', code: 404 });
  const availability = db
    .prepare('SELECT date, available FROM vendor_availability WHERE vendor_id = ? ORDER BY date')
    .all(req.params.id);
  res.json({ vendor, availability });
});

module.exports = router;
