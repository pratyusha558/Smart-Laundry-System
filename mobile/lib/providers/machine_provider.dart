import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/api_service.dart';

class MachineProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Timer? _pollTimer;

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
    if (_machines.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    try {
      _machines = await _api.getMachines();
      errorMessage = null;
    } catch (e) {
      errorMessage = "Could not reach server. Is the backend running?";
    }

    isLoading = false;
    notifyListeners();
  }

  void startPolling() {
    fetchMachines();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => fetchMachines(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<String?> startMachine(String id) async {
    try {
      final updated = await _api.startMachine(id);
      final index = _machines.indexWhere((m) => m.id == id);
      _machines[index] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
