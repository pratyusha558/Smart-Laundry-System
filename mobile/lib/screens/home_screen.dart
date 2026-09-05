import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';
import '../widgets/machine_status_card.dart';
import '../widgets/dashboard_summary.dart';
import 'admin_screen.dart';
import '../widgets/gradient_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<String>? _notificationSub;

  @override
  void initState() {
    super.initState();
    final provider = context.read<MachineProvider>();
    Future.microtask(() => provider.startPolling());

    _notificationSub = provider.notifications.listen((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    });
  }

  @override
  void dispose() {
    context.read<MachineProvider>().stopPolling();
    _notificationSub?.cancel();
    super.dispose();
  }

  void _showAdminPinDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Admin PIN"),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter PIN"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text == "1234") {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminScreen()),
                );
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Incorrect PIN")));
              }
            },
            child: const Text("Enter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final showBanner =
        provider.errorMessage != null && provider.machines.isNotEmpty;

    return GradientScaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_laundry_service_rounded, size: 22),
            SizedBox(width: 8),
            Text("Smart Laundry"),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: "Admin",
            onPressed: () => _showAdminPinDialog(context),
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
