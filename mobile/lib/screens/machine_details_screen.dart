import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../providers/machine_provider.dart';

class MachineDetailsScreen extends StatefulWidget {
  final String machineId;

  const MachineDetailsScreen({super.key, required this.machineId});

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final machine = provider.getById(widget.machineId);

    final minutes = (machine.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (machine.remainingSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(machine.name)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              machine.statusLabel,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Remaining Time: $minutes : $seconds",
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: machine.status == MachineStatus.available
                    ? () async {
                        if (_submitting)
                          return; // guards against double-tap race
                        setState(() => _submitting = true);
                        final error = await provider.startMachine(machine.id);
                        setState(() => _submitting = false);

                        if (!context.mounted) return;

                        if (error != null) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: Text(
                  _submitting
                      ? "STARTING..."
                      : machine.status == MachineStatus.available
                      ? "START / RESERVE"
                      : "NOT AVAILABLE",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
