const express = require('express');
const { v4: uuid } = require('uuid');
const db = require('../../db');
const { authRequired } = require('../../middleware/auth');

const router = express.Router();

function randomBindCode() {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
}

router.post('/register', (req, res) => {
  const { phone, password, name } = req.body || {};
  if (!phone || !password || !name) {
    return res.status(400).json({ error: '请填写手机号、密码和姓名', code: 400 });
  }
  const exists = db.prepare('SELECT id FROM users WHERE phone = ?').get(phone);
  if (exists) return res.status(409).json({ error: '手机号已注册', code: 409 });

  const id = uuid();
  db.prepare('INSERT INTO users (id, phone, password, name) VALUES (?, ?, ?, ?)').run(
    id,
    phone,
    password,
    name
  );

  const token = uuid();
  db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)').run(token, id);
  res.status(201).json({ token, user: { id, phone, name, wedding_id: null } });
});

router.post('/login', (req, res) => {
  const { phone, password } = req.body || {};
  if (!phone || !password) {
    return res.status(400).json({ error: '请输入手机号和密码', code: 400 });
  }
  const user = db
    .prepare('SELECT id, phone, name, wedding_id FROM users WHERE phone = ? AND password = ?')
    .get(phone, password);
  if (!user) return res.status(401).json({ error: '手机号或密码错误', code: 401 });

  const token = uuid();
  db.prepare('INSERT INTO sessions (token, user_id) VALUES (?, ?)').run(token, user.id);
  res.json({ token, user });
});

router.get('/me', authRequired, (req, res) => {
  let wedding = null;
  if (req.user.wedding_id) {
    wedding = db.prepare('SELECT * FROM weddings WHERE id = ?').get(req.user.wedding_id);
  }
  res.json({ user: req.user, wedding });
});

router.post('/bind', authRequired, (req, res) => {
  const { bindCode } = req.body || {};
  if (!bindCode) return res.status(400).json({ error: '请输入绑定码', code: 400 });
  if (req.user.wedding_id) {
    return res.status(400).json({ error: '已绑定婚礼', code: 400 });
  }

  const wedding = db.prepare('SELECT * FROM weddings WHERE bind_code = ?').get(bindCode.toUpperCase());
  if (!wedding) return res.status(404).json({ error: '绑定码无效', code: 404 });

  db.prepare('UPDATE users SET wedding_id = ? WHERE id = ?').run(wedding.id, req.user.id);
  res.json({ ok: true, wedding_id: wedding.id, wedding });
});

router.post('/logout', authRequired, (req, res) => {
  db.prepare('DELETE FROM sessions WHERE token = ?').run(req.token);
  res.json({ ok: true });
});

module.exports = router;
