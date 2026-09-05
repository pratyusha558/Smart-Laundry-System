import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/api_service.dart';

class MachineProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Timer? _pollTimer;
  final StreamController<String> _notificationController =
      StreamController<String>.broadcast();

  List<Machine> _machines = [];
  bool isLoading = false;
  String? errorMessage;

  List<Machine> get machines => _machines;
  Stream<String> get notifications => _notificationController.stream;

  int get availableCount =>
      _machines.where((m) => m.status == MachineStatus.available).length;

  int get occupiedCount =>
      _machines.where((m) => m.status != MachineStatus.available).length;

  Machine getById(String id) => _machines.firstWhere((m) => m.id == id);

  bool isMine(Machine m) => m.startedBy == ApiService.deviceId;

  Future<void> fetchMachines() async {
    if (_machines.isEmpty) {
      isLoading = true;
      notifyListeners();
    }

    final previousStatuses = {for (final m in _machines) m.id: m.status};

    try {
      final updated = await _api.getMachines();

      for (final m in updated) {
        final prevStatus = previousStatuses[m.id];
        if (prevStatus != null && prevStatus != m.status) {
          if (m.status == MachineStatus.running) {
            _notificationController.add("${m.name} started");
          } else if (m.status == MachineStatus.available) {
            _notificationController.add("${m.name} is now available");
          }
        }
      }

      _machines = updated;
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

  Future<String?> startMachine(String id, int durationSeconds) async {
    try {
      await _api.startMachine(id, durationSeconds);
      await fetchMachines(); // single place that detects the transition + notifies
      return null;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }

  Future<String?> stopMachine(String id) async {
    try {
      await _api.stopMachine(id);
      await fetchMachines();
      return null;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    }
  }

  Future<void> adminCompleteMachine(String id) async {
    await _api.adminCompleteMachine(id);
    await fetchMachines();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _notificationController.close();
    super.dispose();
  }
}
