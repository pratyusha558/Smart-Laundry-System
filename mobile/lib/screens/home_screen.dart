import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';
import '../widgets/machine_status_card.dart';
import '../widgets/dashboard_summary.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final machines = provider.machines;

    return Scaffold(
      appBar: AppBar(title: const Text("🧺 Smart Laundry"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "Laundry Status",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DashboardSummary(
            availableCount: provider.availableCount,
            occupiedCount: provider.occupiedCount,
          ),
          const SizedBox(height: 24),
          Text(
            "Machines",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final machine in machines) ...[
            MachineStatusCard(machine: machine),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
