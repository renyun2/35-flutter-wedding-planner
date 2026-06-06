const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired, weddingRequired } = require('../../middleware/auth');
const { hasBookingConflict } = require('../../utils/bookings');

const router = express.Router();

router.get('/', authRequired, weddingRequired, (req, res) => {
  const bookings = db
    .prepare(
      `SELECT b.*, v.name AS vendor_name, v.category AS vendor_category
       FROM bookings b JOIN vendors v ON v.id = b.vendor_id
       WHERE b.wedding_id = ? ORDER BY b.booking_date`
    )
    .all(req.weddingId);
  res.json({ bookings });
});

router.post('/', authRequired, weddingRequired, (req, res) => {
  const { vendorId, bookingDate, note } = req.body || {};
  if (!vendorId || !bookingDate) {
    return res.status(400).json({ error: '请选择供应商和档期', code: 400 });
  }

  const vendor = db.prepare('SELECT * FROM vendors WHERE id = ?').get(vendorId);
  if (!vendor) return res.status(404).json({ error: '供应商不存在', code: 404 });

  const conflict = hasBookingConflict(vendorId, bookingDate);
  if (conflict.conflict) {
    return res.status(409).json({
      error: '该档期已被预约',
      code: 409,
      conflict: true,
    });
  }

  const id = uuid();
  try {
    db.prepare(
      'INSERT INTO bookings (id, wedding_id, vendor_id, booking_date, note) VALUES (?, ?, ?, ?, ?)'
    ).run(id, req.weddingId, vendorId, bookingDate, note || '');
  } catch (e) {
    if (String(e.message).includes('UNIQUE')) {
      return res.status(409).json({ error: '您已预约该供应商此档期', code: 409 });
    }
    throw e;
  }

  res.status(201).json({ booking: db.prepare('SELECT * FROM bookings WHERE id = ?').get(id) });
});

module.exports = router;
