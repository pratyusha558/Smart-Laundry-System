import 'package:flutter/material.dart';
import '../models/machine.dart';

class MachineProvider extends ChangeNotifier {
  final List<Machine> _machines = [
    Machine(id: "m1", name: "Washing Machine #1"),
    Machine(
      id: "m2",
      name: "Washing Machine #2",
      status: MachineStatus.running,
      remainingSeconds: 720,
    ),
    Machine(id: "m3", name: "Washing Machine #3"),
  ];

  List<Machine> get machines => _machines;

  int get availableCount =>
      _machines.where((m) => m.status == MachineStatus.available).length;

  int get occupiedCount =>
      _machines.where((m) => m.status != MachineStatus.available).length;
}
