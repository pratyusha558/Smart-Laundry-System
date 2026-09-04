const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// In-memory data for now — replaced with a real database in M6.
// Shape matches the Flutter Machine model exactly.
let machines = [
  { id: "m1", name: "Washing Machine #1", status: "available", remainingSeconds: 0 },
  { id: "m2", name: "Washing Machine #2", status: "running", remainingSeconds: 720 },
  { id: "m3", name: "Washing Machine #3", status: "available", remainingSeconds: 0 },
];

// GET all machines
app.get("/api/machines", (req, res) => {
  res.json(machines);
});

// GET one machine
app.get("/api/machines/:id", (req, res) => {
  const machine = machines.find((m) => m.id === req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  res.json(machine);
});

// START a machine
app.post("/api/machines/:id/start", (req, res) => {
  const machine = machines.find((m) => m.id === req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  if (machine.status !== "available") {
    return res.status(400).json({ error: "Machine is not available" });
  }
  machine.status = "running";
  machine.remainingSeconds = 1800; // 30 minutes
  res.json(machine);
});

// COMPLETE a machine
app.post("/api/machines/:id/complete", (req, res) => {
  const machine = machines.find((m) => m.id === req.params.id);
  if (!machine) return res.status(404).json({ error: "Machine not found" });
  machine.status = "available";
  machine.remainingSeconds = 0;
  res.json(machine);
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});