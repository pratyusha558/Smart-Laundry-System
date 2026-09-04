import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/api_service.dart';

class MachineProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Machine> _machines = [];
  bool isLoading = false;
  String? errorMessage;

  List<Machine> get machines => _machines;

  int get availableCount =>
      _machines.where((m) => m.status == MachineStatus.available).length;

  int get occupiedCount =>
      _machines.where((m) => m.status != MachineStatus.available).length;

  Machine getById(String id) => _machines.firstWhere((m) => m.id == id);

  Future<void> fetchMachines() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _machines = await _api.getMachines();
    } catch (e) {
      errorMessage = "Could not reach server. Is the backend running?";
    }

    isLoading = false;
    notifyListeners();
  }

  Future<String?> startMachine(String id) async {
    try {
      final updated = await _api.startMachine(id);
      final index = _machines.indexWhere((m) => m.id == id);
      _machines[index] = updated;
      notifyListeners();
      return null; // no error
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }
}
