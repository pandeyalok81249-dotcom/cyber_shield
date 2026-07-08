import 'package:flutter/material.dart';

class CyberCard extends StatelessWidget {
  final Widget child;

  const CyberCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF101722),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }
}