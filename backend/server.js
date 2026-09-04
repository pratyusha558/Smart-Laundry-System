const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

// GET all machines
app.get("/api/machines", (req, res) => {
  const machines = db.prepare("SELECT * FROM machines").all();
  res.json(machines);
});

// GET one machine
app.get("/api/machines/:id", (req, res) => {
  const machine = db
    .prepare("SELECT * FROM machines WHERE id = ?")
    .get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  res.json(machine);
});

// START a machine
app.post("/api/machines/:id/start", (req, res) => {
  const machine = db
    .prepare("SELECT * FROM machines WHERE id = ?")
    .get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  if (machine.status !== "available") {
    return res.status(400).json({ error: "Machine is not available" });
  }

  db.prepare(
    "UPDATE machines SET status = ?, remainingSeconds = ? WHERE id = ?"
  ).run("running", 1800, req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(updated);
});

// COMPLETE a machine
app.post("/api/machines/:id/complete", (req, res) => {
  const machine = db
    .prepare("SELECT * FROM machines WHERE id = ?")
    .get(req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });

  db.prepare(
    "UPDATE machines SET status = ?, remainingSeconds = ? WHERE id = ?"
  ).run("available", 0, req.params.id);

  const updated = db.prepare("SELECT * FROM machines WHERE id = ?").get(req.params.id);
  res.json(updated);
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});