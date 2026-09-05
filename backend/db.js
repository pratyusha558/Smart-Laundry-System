const Database = require("better-sqlite3");
const db = new Database("laundry.db");

db.exec(`
  CREATE TABLE IF NOT EXISTS machines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    status TEXT NOT NULL,
    remainingSeconds INTEGER NOT NULL
  )
`);

try {
  db.exec("ALTER TABLE machines ADD COLUMN endTime INTEGER");
} catch (e) {}

try {
  db.exec("ALTER TABLE machines ADD COLUMN startedBy TEXT");
} catch (e) {}

const count = db.prepare("SELECT COUNT(*) as count FROM machines").get().count;

if (count === 0) {
  const insert = db.prepare(
    "INSERT INTO machines (id, name, status, remainingSeconds, endTime, startedBy) VALUES (?, ?, ?, ?, ?, ?)"
  );
  insert.run("m1", "Washing Machine #1", "available", 0, null, null);
  insert.run("m2", "Washing Machine #2", "available", 0, null, null);
  insert.run("m3", "Washing Machine #3", "available", 0, null, null);
}

module.exports = db;