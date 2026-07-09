import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import 'cyber_card.dart';

class ResultCard extends StatelessWidget {
  final ScanResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.isSafe
        ? Colors.greenAccent
        : result.isWarning
            ? Colors.orangeAccent
            : Colors.redAccent;

    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.status,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 12),
            Text("Risk Score: ${result.riskScore}/100"),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: result.riskScore / 100,
              color: color,
              backgroundColor: Colors.white12,
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            if (result.positives.isNotEmpty) ...[
              const Text("Positive checks:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.positives.map((p) => Text("✅ $p")),
              const SizedBox(height: 12),
            ],
            if (result.warnings.isNotEmpty) ...[
              const Text("Warnings:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...result.warnings.map((w) => Text("⚠️ $w")),
              const SizedBox(height: 12),
            ],
            const Text("Advice:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(result.advice),
          ],
        ),
      ),
    );
  }
}