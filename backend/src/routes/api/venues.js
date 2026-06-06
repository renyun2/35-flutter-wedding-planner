const express = require('express');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');

const router = express.Router();

router.get('/', authRequired, (req, res) => {
  const { minTables, maxPrice, district } = req.query;
  let sql = 'SELECT * FROM venues WHERE 1=1';
  const params = [];

  if (minTables) {
    sql += ' AND max_tables >= ?';
    params.push(Number(minTables));
  }
  if (maxPrice) {
    sql += ' AND price_per_table <= ?';
    params.push(Number(maxPrice));
  }
  if (district) {
    sql += ' AND district = ?';
    params.push(district);
  }
  sql += ' ORDER BY price_per_table ASC';

  const venues = db.prepare(sql).all(...params);
  res.json({ venues });
});

router.get('/:id', authRequired, (req, res) => {
  const venue = db.prepare('SELECT * FROM venues WHERE id = ?').get(req.params.id);
  if (!venue) return res.status(404).json({ error: '酒店不存在', code: 404 });
  res.json({ venue });
});

module.exports = router;
