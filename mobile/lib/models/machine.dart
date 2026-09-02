enum MachineStatus { available, reserved, running, completed }

class Machine {
  final String id;
  final String name;
  MachineStatus status;
  int remainingSeconds;

  Machine({
    required this.id,
    required this.name,
    this.status = MachineStatus.available,
    this.remainingSeconds = 0,
  });

  String get statusLabel {
    switch (status) {
      case MachineStatus.available:
        return "Available";
      case MachineStatus.reserved:
        return "Reserved";
      case MachineStatus.running:
        return "Running";
      case MachineStatus.completed:
        return "Completed";
    }
  }
}
