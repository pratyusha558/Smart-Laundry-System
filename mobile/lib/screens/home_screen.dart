import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';
import '../widgets/machine_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final machines = context.watch<MachineProvider>().machines;

    return Scaffold(
      appBar: AppBar(title: const Text("🧺 Smart Laundry"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            MachineStatusCard(machine: machines[0]),
            const Spacer(),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("START WASH", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
