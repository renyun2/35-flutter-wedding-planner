const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const dbPath = process.env.WEDDING_DB_PATH || path.join(dataDir, 'wedding.db');
const db = new Database(dbPath);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

function initSchema() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      phone TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL DEFAULT '123456',
      name TEXT NOT NULL,
      wedding_id TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS sessions (
      token TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS weddings (
      id TEXT PRIMARY KEY,
      bride_name TEXT NOT NULL,
      groom_name TEXT NOT NULL,
      wedding_date TEXT,
      date_locked INTEGER NOT NULL DEFAULT 0,
      deposit_paid REAL NOT NULL DEFAULT 0,
      total_budget REAL NOT NULL DEFAULT 200000,
      bind_code TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS budget_items (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      category TEXT NOT NULL,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      paid_amount REAL NOT NULL DEFAULT 0,
      status TEXT NOT NULL CHECK(status IN ('paid','pending')) DEFAULT 'pending',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS venues (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      address TEXT NOT NULL DEFAULT '',
      district TEXT NOT NULL DEFAULT '',
      min_tables INTEGER NOT NULL DEFAULT 10,
      max_tables INTEGER NOT NULL DEFAULT 50,
      price_per_table REAL NOT NULL,
      image_url TEXT NOT NULL DEFAULT '',
      description TEXT NOT NULL DEFAULT '',
      distance_km REAL NOT NULL DEFAULT 3.5
    );

    CREATE TABLE IF NOT EXISTS venue_inquiries (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      venue_id TEXT NOT NULL REFERENCES venues(id),
      tables INTEGER NOT NULL,
      message TEXT NOT NULL DEFAULT '',
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS vendors (
      id TEXT PRIMARY KEY,
      category TEXT NOT NULL CHECK(category IN ('photo','video','makeup','host')),
      name TEXT NOT NULL,
      price REAL NOT NULL,
      rating REAL NOT NULL DEFAULT 4.5,
      description TEXT NOT NULL DEFAULT '',
      image_url TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS vendor_availability (
      id TEXT PRIMARY KEY,
      vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
      date TEXT NOT NULL,
      available INTEGER NOT NULL DEFAULT 1,
      UNIQUE(vendor_id, date)
    );

    CREATE TABLE IF NOT EXISTS bookings (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      vendor_id TEXT NOT NULL REFERENCES vendors(id),
      booking_date TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'confirmed',
      note TEXT NOT NULL DEFAULT '',
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(wedding_id, vendor_id, booking_date)
    );

    CREATE TABLE IF NOT EXISTS guests (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      name TEXT NOT NULL,
      phone TEXT NOT NULL DEFAULT '',
      table_number INTEGER,
      rsvp_status TEXT NOT NULL CHECK(rsvp_status IN ('pending','accepted','declined')) DEFAULT 'pending',
      side TEXT NOT NULL CHECK(side IN ('bride','groom')) DEFAULT 'bride'
    );

    CREATE TABLE IF NOT EXISTS seating (
      wedding_id TEXT PRIMARY KEY REFERENCES weddings(id) ON DELETE CASCADE,
      layout_json TEXT NOT NULL DEFAULT '[]',
      updated_at TEXT NOT NULL DEFAULT (datetime('now'))
    );

    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      title TEXT NOT NULL,
      due_date TEXT,
      completed INTEGER NOT NULL DEFAULT 0,
      category TEXT NOT NULL DEFAULT 'general'
    );

    CREATE TABLE IF NOT EXISTS timeline_items (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      time_minutes INTEGER NOT NULL,
      title TEXT NOT NULL,
      note TEXT NOT NULL DEFAULT ''
    );

    CREATE TABLE IF NOT EXISTS inspirations (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      image_url TEXT NOT NULL,
      tags_json TEXT NOT NULL DEFAULT '[]'
    );

    CREATE TABLE IF NOT EXISTS contracts (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      vendor_name TEXT NOT NULL,
      title TEXT NOT NULL,
      pdf_url TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'signed'
    );

    CREATE TABLE IF NOT EXISTS notifications (
      id TEXT PRIMARY KEY,
      wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
      user_id TEXT REFERENCES users(id),
      title TEXT NOT NULL,
      body TEXT NOT NULL DEFAULT '',
      read INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);
}

initSchema();

module.exports = db;
