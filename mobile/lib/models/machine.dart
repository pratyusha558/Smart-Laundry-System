enum MachineStatus { available, reserved, running, completed }

MachineStatus statusFromString(String s) {
  switch (s) {
    case "reserved":
      return MachineStatus.reserved;
    case "running":
      return MachineStatus.running;
    case "completed":
      return MachineStatus.completed;
    default:
      return MachineStatus.available;
  }
}

class Machine {
  final String id;
  final String name;
  MachineStatus status;
  int remainingSeconds;
  String? startedBy;

  Machine({
    required this.id,
    required this.name,
    this.status = MachineStatus.available,
    this.remainingSeconds = 0,
    this.startedBy,
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['id'],
      name: json['name'],
      status: statusFromString(json['status']),
      remainingSeconds: json['remainingSeconds'],
      startedBy: json['startedBy'],
    );
  }

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
