const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

const SESSION_SECONDS = parseInt(process.env.SESSION_SECONDS) || 1800;

function resolveMachine(machine) {
  if (machine.status === "running" && machine.endTime) {
    const remaining = Math.round((machine.endTime - Date.now()) / 1000);
    if (remaining <= 0) {
      db.prepare(
        "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL, startedBy = NULL WHERE id = ?"
      ).run(machine.id);
      return { ...machine, status: "available", remainingSeconds: 0, endTime: null, startedBy: null };
    }
    return { ...machine, remainingSeconds: remaining };
  }
  return machine;
}

app.get("/api/machines", (req, res) => {
  const machines = db.prepare("SELECT * FROM machines").all().map(resolveMachine);
  res.json(machines);
});

app.get("/api/machines/:id", (req, res) => {
  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  res.json(resolveMachine(machine));
});

app.post("/api/machines/:id/start", (req, res) => {
  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  const resolved = resolveMachine(machine);
  if (resolved.status !== "available") {
    return res.status(400).json({ error: "Machine is not available" });
  }

  const requested = parseInt(req.body?.durationSeconds);
  const duration = Number.isFinite(requested) && requested > 0 ? requested : SESSION_SECONDS;
  const deviceId = req.body?.deviceId || null;

  const endTime = Date.now() + duration * 1000;
  db.prepare(
    "UPDATE machines SET status = 'running', remainingSeconds = ?, endTime = ?, startedBy = ? WHERE id = ?"
  ).run(duration, endTime, deviceId, req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(resolveMachine(updated));
});

// User-initiated stop — must match the device that started it
app.post("/api/machines/:id/complete", (req, res) => {
  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  const deviceId = req.body?.deviceId || null;
  if (machine.startedBy && machine.startedBy !== deviceId) {
    return res.status(403).json({ error: "Only the user who started this machine can stop it" });
  }

  db.prepare(
    "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL, startedBy = NULL WHERE id = ?"
  ).run(req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(updated);
});

// Admin override — always allowed, no ownership check (used only by the Admin screen)
app.post("/api/machines/:id/admin-complete", (req, res) => {
  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  db.prepare(
    "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL, startedBy = NULL WHERE id = ?"
  ).run(req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(updated);
});

const HARDWARE_SECRET = "laundry-esp32-key"; // shared secret, change if you want
const CURRENT_THRESHOLD_AMPS = 0.3; // tune this after real readings come in

// Called directly by the ESP32 over WiFi with live current sensor readings
app.post("/api/machines/:id/hardware-status", (req, res) => {
  const { secret, current } = req.body || {};

  if (secret !== HARDWARE_SECRET) {
    return res.status(403).json({ error: "Invalid hardware key" });
  }
  if (typeof current !== "number") {
    return res.status(400).json({ error: "current (amps) is required" });
  }

  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  const resolved = resolveMachine(machine);
  const isRunning = current > CURRENT_THRESHOLD_AMPS;

  if (isRunning && resolved.status === "available") {
    // Hardware detected the wash starting on its own
    const endTime = Date.now() + SESSION_SECONDS * 1000;
    db.prepare(
      "UPDATE machines SET status = 'running', remainingSeconds = ?, endTime = ?, startedBy = 'hardware' WHERE id = ?"
    ).run(SESSION_SECONDS, endTime, req.params.id);
  } else if (!isRunning && resolved.status === "running" && resolved.startedBy === "hardware") {
    // Only auto-release sessions hardware itself started — never a real user's reservation
    db.prepare(
      "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL, startedBy = NULL WHERE id = ?"
    ).run(req.params.id);
  }

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(resolveMachine(updated));
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});