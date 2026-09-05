const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

const SESSION_SECONDS = parseInt(process.env.SESSION_SECONDS) || 1800; // 30 min default, override for demo

// Computes live remainingSeconds from endTime, auto-completes if time is up.
function resolveMachine(machine) {
  if (machine.status === "running" && machine.endTime) {
    const remaining = Math.round((machine.endTime - Date.now()) / 1000);
    if (remaining <= 0) {
      db.prepare(
        "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL WHERE id = ?"
      ).run(machine.id);
      return { ...machine, status: "available", remainingSeconds: 0, endTime: null };
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

  const endTime = Date.now() + SESSION_SECONDS * 1000;
  db.prepare(
    "UPDATE machines SET status = 'running', remainingSeconds = ?, endTime = ? WHERE id = ?"
  ).run(SESSION_SECONDS, endTime, req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(resolveMachine(updated));
});

app.post("/api/machines/:id/complete", (req, res) => {
  const machine = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  db.prepare(
    "UPDATE machines SET status = 'available', remainingSeconds = 0, endTime = NULL WHERE id = ?"
  ).run(req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(updated);
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});