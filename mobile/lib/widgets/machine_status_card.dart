import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../screens/machine_details_screen.dart';

class MachineStatusCard extends StatelessWidget {
  final Machine machine;

  const MachineStatusCard({super.key, required this.machine});

  Color get _statusColor {
    switch (machine.status) {
      case MachineStatus.available:
        return Colors.green;
      case MachineStatus.reserved:
        return Colors.orange;
      case MachineStatus.running:
        return Colors.blue;
      case MachineStatus.completed:
        return Colors.grey;
    }
  }

  String get _statusEmoji {
    switch (machine.status) {
      case MachineStatus.available:
        return "🟢";
      case MachineStatus.reserved:
        return "🟠";
      case MachineStatus.running:
        return "🔵";
      case MachineStatus.completed:
        return "⚪";
    }
  }

  String get _formattedTime {
    final minutes = (machine.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (machine.remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes : $seconds";
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineDetailsScreen(machineId: machine.id),
          ),
        );
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                machine.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "$_statusEmoji ${machine.statusLabel}",
                style: TextStyle(
                  fontSize: 28,
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text("Remaining Time", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                _formattedTime,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
