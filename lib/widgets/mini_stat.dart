import 'package:flutter/material.dart';
import 'cyber_card.dart';

class MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const MiniStat({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
