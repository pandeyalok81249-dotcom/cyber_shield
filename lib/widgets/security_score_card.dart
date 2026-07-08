import 'package:flutter/material.dart';
import 'cyber_card.dart';

class SecurityScoreCard extends StatelessWidget {
  const SecurityScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Security Score", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              "96/100",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const LinearProgressIndicator(
                value: 0.96,
                minHeight: 12,
                backgroundColor: Colors.white12,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            const Text("Your device looks protected in basic checks."),
          ],
        ),
      ),
    );
  }
}
