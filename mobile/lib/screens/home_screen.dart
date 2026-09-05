import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';
import '../widgets/machine_status_card.dart';
import '../widgets/dashboard_summary.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MachineProvider>().startPolling());
  }

  @override
  void dispose() {
    context.read<MachineProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final showBanner =
        provider.errorMessage != null && provider.machines.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧺 Smart Laundry"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: "Admin",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (showBanner)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: const Text(
                "⚠ Connection lost — showing last known data",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchMachines(),
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MachineProvider provider) {
    if (provider.isLoading && provider.machines.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.machines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return ListView(
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
        for (final machine in provider.machines) ...[
          MachineStatusCard(machine: machine),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
