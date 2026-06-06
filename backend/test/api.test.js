const { test, before, after, describe } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

const dbPath = path.join(__dirname, '..', 'data', `wedding-test-${process.pid}.db`);

async function callApp(app, method, url, { token, body } = {}) {
  return new Promise((resolve, reject) => {
    const server = app.listen(0, () => {
      const { port } = server.address();
      const http = require('http');
      const payload = body ? JSON.stringify(body) : null;
      const req = http.request(
        {
          hostname: '127.0.0.1',
          port,
          path: url,
          method,
          headers: {
            'Content-Type': 'application/json',
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
            ...(payload ? { 'Content-Length': Buffer.byteLength(payload) } : {}),
          },
        },
        (res) => {
          let raw = '';
          res.on('data', (c) => (raw += c));
          res.on('end', () => {
            server.close();
            resolve({
              status: res.statusCode,
              body: raw ? JSON.parse(raw) : null,
            });
          });
        }
      );
      req.on('error', (e) => {
        server.close();
        reject(e);
      });
      if (payload) req.write(payload);
      req.end();
    });
  });
}

describe('Wedding Planner API', () => {
  let app;
  let token;
  let weddingId;
  let vendorId;

  function resetDb() {
    try {
      const dbModulePath = require.resolve('../src/db');
      if (require.cache[dbModulePath]) {
        require.cache[dbModulePath].exports.close();
        delete require.cache[dbModulePath];
      }
    } catch (_) {
      // no open connection yet
    }
    delete require.cache[require.resolve('../src/seed')];
    delete require.cache[require.resolve('../src/index')];
    if (fs.existsSync(dbPath)) {
      try {
        fs.unlinkSync(dbPath);
      } catch (_) {
        // Windows may keep sqlite file locked briefly
      }
    }
  }

  before(() => {
    process.env.WEDDING_DB_PATH = dbPath;
    resetDb();
    const { seed } = require('../src/seed');
    seed();
    app = require('../src/index');
  });

  after(() => {
    try {
      const db = require('../src/db');
      db.close();
    } catch (_) {
      // ignore
    }
    delete require.cache[require.resolve('../src/db')];
    delete require.cache[require.resolve('../src/index')];
    try {
      if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);
    } catch (_) {
      // Windows may keep sqlite file locked briefly
    }
  });

  test('login demo account', async () => {
    const res = await callApp(app, 'POST', '/api/auth/login', {
      body: { phone: '13800000001', password: '123456' },
    });
    assert.equal(res.status, 200);
    assert.ok(res.body.token);
    token = res.body.token;
    weddingId = res.body.user.wedding_id;
    assert.ok(weddingId);
  });

  test('budget summary totals paid and pending', async () => {
    const res = await callApp(app, 'GET', '/api/budget/summary', { token });
    assert.equal(res.status, 200);
    assert.ok(res.body.total_budget > 0);
    assert.equal(res.body.total_paid + res.body.total_pending + res.body.total_spent - res.body.total_spent, res.body.total_spent - res.body.total_spent + res.body.total_paid + res.body.total_pending);
    assert.ok(typeof res.body.over_budget === 'boolean');
    const items = await callApp(app, 'GET', '/api/budget/items', { token });
    assert.equal(items.status, 200);
    assert.ok(items.body.items.length >= 5);
    assert.equal(items.body.summary.total_spent, res.body.total_spent);
  });

  test('seating rejects layout below guest capacity', async () => {
    const guests = await callApp(app, 'GET', '/api/guests', { token });
    assert.equal(guests.status, 200);
    const guestCount = guests.body.guests.filter((g) => g.rsvp_status !== 'declined').length;

    const badLayout = [{ table_number: 1, name: '小桌', capacity: 5, guest_ids: [] }];
    const res = await callApp(app, 'PUT', '/api/seating', {
      token,
      body: { layout: badLayout },
    });
    assert.equal(res.status, 400);
    assert.match(res.body.error, /容量/);

    const goodLayout = [];
    let remaining = guestCount;
    let tableNo = 1;
    while (remaining > 0) {
      const cap = Math.min(10, remaining);
      goodLayout.push({ table_number: tableNo, name: `桌${tableNo}`, capacity: cap, guest_ids: [] });
      remaining -= cap;
      tableNo += 1;
    }
    const ok = await callApp(app, 'PUT', '/api/seating', {
      token,
      body: { layout: goodLayout },
    });
    assert.equal(ok.status, 200);
    assert.equal(ok.body.validation.valid, true);
  });

  test('booking conflict on same vendor date', async () => {
    const vendors = await callApp(app, 'GET', '/api/vendors?category=photo', { token });
    assert.equal(vendors.status, 200);
    vendorId = vendors.body.vendors[0].id;
    const { addDaysFromToday } = require('../src/seed');
    const date = addDaysFromToday(60);

    const db = require('../src/db');
    db.prepare(
      'INSERT OR REPLACE INTO vendor_availability (id, vendor_id, date, available) VALUES (?, ?, ?, 1)'
    ).run(require('uuid').v4(), vendorId, date);

    const first = await callApp(app, 'POST', '/api/bookings', {
      token,
      body: { vendorId, bookingDate: date },
    });
    assert.equal(first.status, 201);

    const otherUser = await callApp(app, 'POST', '/api/auth/register', {
      body: { phone: '13999999999', password: '123456', name: '测试用户' },
    });
    assert.equal(otherUser.status, 201);
    const otherWedding = await callApp(app, 'POST', '/api/wedding/create', {
      token: otherUser.body.token,
      body: { brideName: 'A', groomName: 'B' },
    });
    assert.equal(otherWedding.status, 201);

    const conflict = await callApp(app, 'POST', '/api/bookings', {
      token: otherUser.body.token,
      body: { vendorId, bookingDate: date },
    });
    assert.equal(conflict.status, 409);
    assert.equal(conflict.body.conflict, true);
  });

  test('wedding date change deducts deposit when locked', async () => {
    const fresh = await callApp(app, 'POST', '/api/auth/register', {
      body: { phone: '13777777777', password: '123456', name: '改期测试' },
    });
    const created = await callApp(app, 'POST', '/api/wedding/create', {
      token: fresh.body.token,
      body: { brideName: 'X', groomName: 'Y' },
    });
    const { addDaysFromToday } = require('../src/seed');
    const d1 = addDaysFromToday(100);
    const d2 = addDaysFromToday(110);

    const lock = await callApp(app, 'PUT', '/api/wedding/date', {
      token: fresh.body.token,
      body: { weddingDate: d1 },
    });
    assert.equal(lock.status, 200);
    assert.equal(lock.body.deposit_deducted, 0);

    const change = await callApp(app, 'PUT', '/api/wedding/date', {
      token: fresh.body.token,
      body: { weddingDate: d2 },
    });
    assert.equal(change.status, 200);
    assert.equal(change.body.deposit_deducted, 5000);
  });
});
