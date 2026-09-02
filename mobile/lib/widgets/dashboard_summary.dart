import 'package:flutter/material.dart';

class DashboardSummary extends StatelessWidget {
  final int availableCount;
  final int occupiedCount;

  const DashboardSummary({
    super.key,
    required this.availableCount,
    required this.occupiedCount,
  });

  Widget _statCard(String label, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withValues(alpha: 0.1),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(
                "$count",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard("Available", availableCount, Colors.green),
        const SizedBox(width: 12),
        _statCard("Occupied", occupiedCount, Colors.orange),
      ],
    );
  }
}
