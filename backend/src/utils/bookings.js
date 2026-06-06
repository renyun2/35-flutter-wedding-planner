const db = require('../db');

function hasBookingConflict(vendorId, bookingDate, excludeWeddingId = null) {
  const row = db
    .prepare(
      `SELECT b.id, b.wedding_id FROM bookings b
       WHERE b.vendor_id = ? AND b.booking_date = ? AND b.status = 'confirmed'
       ${excludeWeddingId ? 'AND b.wedding_id != ?' : ''}
       LIMIT 1`
    )
    .get(...(excludeWeddingId ? [vendorId, bookingDate, excludeWeddingId] : [vendorId, bookingDate]));

  if (row) {
    return { conflict: true, existing: row };
  }

  const avail = db
    .prepare('SELECT available FROM vendor_availability WHERE vendor_id = ? AND date = ?')
    .get(vendorId, bookingDate);

  if (avail && !avail.available) {
    return { conflict: true, reason: 'vendor_unavailable' };
  }

  return { conflict: false };
}

module.exports = { hasBookingConflict };
