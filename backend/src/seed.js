const { v4: uuid } = require('uuid');
const db = require('./db');

function addDaysFromToday(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

function seed() {
  const venueCount = db.prepare('SELECT COUNT(*) AS c FROM venues').get().c;
  if (venueCount >= 10) return;

  db.exec('DELETE FROM notifications');
  db.exec('DELETE FROM contracts');
  db.exec('DELETE FROM timeline_items');
  db.exec('DELETE FROM tasks');
  db.exec('DELETE FROM bookings');
  db.exec('DELETE FROM vendor_availability');
  db.exec('DELETE FROM venue_inquiries');
  db.exec('DELETE FROM guests');
  db.exec('DELETE FROM seating');
  db.exec('DELETE FROM budget_items');
  db.exec('DELETE FROM sessions');
  db.exec('DELETE FROM users');
  db.exec('DELETE FROM weddings');
  db.exec('DELETE FROM vendors');
  db.exec('DELETE FROM venues');
  db.exec('DELETE FROM inspirations');

  const districts = ['朝阳区', '海淀区', '西城区', '东城区', '丰台区'];
  const venueNames = [
    '皇家花园酒店', '铂悦宴会厅', '星河婚礼中心', '悦来大酒店', '锦绣华庭',
    '水晶宫宴会', '盛世婚礼庄园', '金悦轩', '丽都婚礼会馆', '天禧大酒店',
    '御花园', '禧悦汇',
  ];

  const insertVenue = db.prepare(
    `INSERT INTO venues (id, name, address, district, min_tables, max_tables, price_per_table, image_url, description, distance_km)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  );

  venueNames.forEach((name, i) => {
    insertVenue.run(
      uuid(),
      name,
      `${districts[i % districts.length]}婚礼路 ${100 + i} 号`,
      districts[i % districts.length],
      8 + (i % 5),
      20 + i * 3,
      2800 + i * 350,
      `https://picsum.photos/seed/venue${i}/800/600`,
      `${name} 提供一站式婚礼服务，含布置与音响。`,
      1.5 + (i % 8) * 0.8
    );
  });

  const categories = ['photo', 'video', 'makeup', 'host'];
  const categoryLabels = { photo: '摄影', video: '摄像', makeup: '化妆', host: '主持' };
  const insertVendor = db.prepare(
    `INSERT INTO vendors (id, category, name, price, rating, description, image_url)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );
  const insertAvail = db.prepare(
    'INSERT INTO vendor_availability (id, vendor_id, date, available) VALUES (?, ?, ?, ?)'
  );

  let vendorIndex = 0;
  for (const cat of categories) {
    for (let j = 1; j <= 8; j += 1) {
      const id = uuid();
      insertVendor.run(
        id,
        cat,
        `${categoryLabels[cat]}工作室 ${String.fromCharCode(64 + j)}`,
        3000 + vendorIndex * 500,
        4.2 + (j % 8) * 0.1,
        `专业${categoryLabels[cat]}团队，婚礼案例丰富。`,
        `https://picsum.photos/seed/vendor${vendorIndex}/600/400`
      );
      for (let d = 30; d <= 120; d += 15) {
        insertAvail.run(uuid(), id, addDaysFromToday(d), d % 45 === 0 ? 0 : 1);
      }
      vendorIndex += 1;
    }
  }

  const weddingId = uuid();
  const bindCode = 'DEMO01';
  const weddingDate = addDaysFromToday(90);

  db.prepare(
    `INSERT INTO weddings (id, bride_name, groom_name, wedding_date, date_locked, total_budget, bind_code)
     VALUES (?, ?, ?, ?, 1, ?, ?)`
  ).run(weddingId, '林小雨', '陈浩然', weddingDate, 200000, bindCode);

  const userA = uuid();
  const userB = uuid();
  db.prepare('INSERT INTO users (id, phone, password, name, wedding_id) VALUES (?, ?, ?, ?, ?)').run(
    userA,
    '13800000001',
    '123456',
    '林小雨',
    weddingId
  );
  db.prepare('INSERT INTO users (id, phone, password, name, wedding_id) VALUES (?, ?, ?, ?, ?)').run(
    userB,
    '13800000002',
    '123456',
    '陈浩然',
    weddingId
  );

  const insertBudget = db.prepare(
    `INSERT INTO budget_items (id, wedding_id, category, title, amount, paid_amount, status)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );
  const budgetRows = [
    ['酒店', '婚宴定金', 30000, 30000, 'paid'],
    ['酒店', '婚宴尾款', 80000, 0, 'pending'],
    ['四大', '摄影套餐', 12000, 6000, 'pending'],
    ['四大', '摄像套餐', 10000, 10000, 'paid'],
    ['四大', '化妆造型', 8000, 0, 'pending'],
    ['布置', '现场布置', 35000, 15000, 'pending'],
    ['其他', '婚车租赁', 6000, 6000, 'paid'],
  ];
  budgetRows.forEach(([cat, title, amount, paid, status]) => {
    insertBudget.run(uuid(), weddingId, cat, title, amount, paid, status);
  });

  const insertGuest = db.prepare(
    `INSERT INTO guests (id, wedding_id, name, phone, table_number, rsvp_status, side)
     VALUES (?, ?, ?, ?, ?, ?, ?)`
  );
  const surnames = ['张', '王', '李', '赵', '刘', '陈', '杨', '黄', '周', '吴'];
  for (let i = 1; i <= 80; i += 1) {
    insertGuest.run(
      uuid(),
      weddingId,
      `${surnames[i % surnames.length]}${i}号宾客`,
      `138${String(10000000 + i).slice(0, 8)}`,
      Math.ceil(i / 10),
      i % 7 === 0 ? 'declined' : i % 3 === 0 ? 'pending' : 'accepted',
      i % 2 === 0 ? 'groom' : 'bride'
    );
  }

  const tables = [];
  for (let t = 1; t <= 10; t += 1) {
    tables.push({ table_number: t, name: `第${t}桌`, capacity: 10, guest_ids: [] });
  }
  db.prepare('INSERT INTO seating (wedding_id, layout_json) VALUES (?, ?)').run(
    weddingId,
    JSON.stringify(tables)
  );

  const insertTask = db.prepare(
    'INSERT INTO tasks (id, wedding_id, title, due_date, completed, category) VALUES (?, ?, ?, ?, ?, ?)'
  );
  const tasks = [
    ['确定婚期', addDaysFromToday(-30), 1, 'planning'],
    ['预订酒店', addDaysFromToday(-20), 1, 'venue'],
    ['选定四大金刚', addDaysFromToday(10), 0, 'vendor'],
    ['发送请柬', addDaysFromToday(30), 0, 'guest'],
    ['确认座位', addDaysFromToday(60), 0, 'seating'],
  ];
  tasks.forEach(([title, due, done, cat]) => {
    insertTask.run(uuid(), weddingId, title, due, done, cat);
  });

  const insertTimeline = db.prepare(
    'INSERT INTO timeline_items (id, wedding_id, time_minutes, title, note) VALUES (?, ?, ?, ?, ?)'
  );
  const timeline = [
    [360, '新娘化妆', '化妆师到场'],
    [480, '接亲出发', '婚车集合'],
    [540, '迎亲仪式', ''],
    [660, '典礼开始', '主舞台'],
    [720, '婚宴开席', ''],
    [900, '送客', ''],
  ];
  timeline.forEach(([mins, title, note]) => {
    insertTimeline.run(uuid(), weddingId, mins, title, note);
  });

  const insertContract = db.prepare(
    'INSERT INTO contracts (id, wedding_id, vendor_name, title, pdf_url, status) VALUES (?, ?, ?, ?, ?, ?)'
  );
  insertContract.run(
    uuid(),
    weddingId,
    '摄影工作室 A',
    '婚礼摄影服务合同',
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'signed'
  );
  insertContract.run(
    uuid(),
    weddingId,
    '铂悦宴会厅',
    '婚宴场地合同',
    'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
    'pending'
  );

  const insertNotif = db.prepare(
    'INSERT INTO notifications (id, wedding_id, user_id, title, body, read) VALUES (?, ?, ?, ?, ?, ?)'
  );
  insertNotif.run(uuid(), weddingId, userA, '婚期已锁定', `婚礼定于 ${weddingDate}`, 1);
  insertNotif.run(uuid(), weddingId, userB, '预算提醒', '布置类支出接近上限', 0);
  insertNotif.run(uuid(), weddingId, null, '任务提醒', '请在本周内确认四大金刚档期', 0);

  for (let i = 0; i < 12; i += 1) {
    db.prepare(
      `INSERT INTO inspirations (id, title, image_url, tags_json) VALUES (?, ?, ?, ?)`
    ).run(
      uuid(),
      `婚礼灵感 ${i + 1}`,
      `https://picsum.photos/seed/insp${i}/800/600`,
      JSON.stringify(['中式', '户外', '简约'].slice(0, (i % 3) + 1))
    );
  }

  console.log('Seed complete: venues, vendors, demo wedding with 80 guests');
}

module.exports = { seed, addDaysFromToday };
