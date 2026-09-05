import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../screens/machine_details_screen.dart';
import 'dart:ui';

class MachineStatusCard extends StatelessWidget {
  final Machine machine;

  const MachineStatusCard({super.key, required this.machine});

  Color get _statusColor {
    switch (machine.status) {
      case MachineStatus.available:
        return const Color(0xFF4CAF50);
      case MachineStatus.reserved:
        return const Color(0xFFFFA726);
      case MachineStatus.running:
        return const Color(0xFF9C27B0);
      case MachineStatus.completed:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get _statusIcon {
    switch (machine.status) {
      case MachineStatus.available:
        return Icons.check_circle_rounded;
      case MachineStatus.reserved:
        return Icons.schedule_rounded;
      case MachineStatus.running:
        return Icons.local_laundry_service_rounded;
      case MachineStatus.completed:
        return Icons.done_all_rounded;
    }
  }

  String get _formattedTime {
    final minutes = (machine.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (machine.remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MachineDetailsScreen(machineId: machine.id),
          ),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon, color: color, size: 26),
              ),
              const SizedBox(width: 14),

              // Name + status chip
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        machine.statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Remaining time
              if (machine.status == MachineStatus.running) ...[
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 6),
              ],

              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }
}
