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

const count = db.prepare("SELECT COUNT(*) as count FROM machines").get().count;

if (count === 0) {
  const insert = db.prepare(
    "INSERT INTO machines (id, name, status, remainingSeconds) VALUES (?, ?, ?, ?)"
  );
  insert.run("m1", "Washing Machine #1", "available", 0);
  insert.run("m2", "Washing Machine #2", "running", 720);
  insert.run("m3", "Washing Machine #3", "available", 0);
}

module.exports = db;