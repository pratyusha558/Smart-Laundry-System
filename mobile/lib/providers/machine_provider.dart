import 'package:flutter/material.dart';
import '../models/machine.dart';

class MachineProvider extends ChangeNotifier {
  final List<Machine> _machines = [
    Machine(id: "m1", name: "Washing Machine #1"),
  ];

  List<Machine> get machines => _machines;

  int get availableCount =>
      _machines.where((m) => m.status == MachineStatus.available).length;

  int get occupiedCount =>
      _machines.where((m) => m.status != MachineStatus.available).length;
}
