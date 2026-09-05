import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../providers/machine_provider.dart';
import '../widgets/gradient_scaffold.dart';

class MachineDetailsScreen extends StatefulWidget {
  final String machineId;

  const MachineDetailsScreen({super.key, required this.machineId});

  @override
  State<MachineDetailsScreen> createState() => _MachineDetailsScreenState();
}

class _MachineDetailsScreenState extends State<MachineDetailsScreen> {
  bool _submitting = false;
  int _selectedMinutes = 30;

  static const List<int> _durationOptions = [1, 5, 10, 15, 20, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final machine = provider.getById(widget.machineId);
    final mine = provider.isMine(machine);

    final minutes = (machine.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (machine.remainingSeconds % 60).toString().padLeft(2, '0');

    return GradientScaffold(
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
            const SizedBox(height: 20),

            if (machine.status == MachineStatus.available) ...[
              const Text(
                "Select wash duration:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButton<int>(
                value: _selectedMinutes,
                isExpanded: true,
                items: _durationOptions
                    .map(
                      (m) =>
                          DropdownMenuItem(value: m, child: Text("$m minutes")),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedMinutes = value);
                },
              ),
            ],

            if (machine.status == MachineStatus.running && !mine)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "In use by another user",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),

            const Spacer(),

            if (machine.status == MachineStatus.available)
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_submitting) return;
                    setState(() => _submitting = true);
                    final error = await provider.startMachine(
                      machine.id,
                      _selectedMinutes * 60,
                    );
                    setState(() => _submitting = false);

                    if (!context.mounted) return;

                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    _submitting ? "STARTING..." : "START / RESERVE",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              )
            else if (machine.status == MachineStatus.running && mine)
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (_submitting) return;
                    setState(() => _submitting = true);
                    final error = await provider.stopMachine(machine.id);
                    setState(() => _submitting = false);

                    if (!context.mounted) return;

                    if (error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    _submitting ? "STOPPING..." : "STOP EARLY",
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            else
              const SizedBox(
                height: 55,
                child: Center(child: Text("NOT AVAILABLE")),
              ),
          ],
        ),
      ),
    );
  }
}
