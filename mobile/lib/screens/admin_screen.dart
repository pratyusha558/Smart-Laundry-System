import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/machine.dart';
import '../providers/machine_provider.dart';
import '../widgets/gradient_scaffold.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();

    return GradientScaffold(
      appBar: AppBar(title: const Text("Admin: Machine Control")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final machine in provider.machines)
            Card(
              child: ListTile(
                title: Text(machine.name),
                subtitle: Text(
                  "${machine.statusLabel} • ${machine.remainingSeconds}s left",
                ),
                trailing: ElevatedButton(
                  onPressed: machine.status == MachineStatus.running
                      ? () => provider.adminCompleteMachine(machine.id)
                      : null,
                  child: const Text("Force Complete"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
