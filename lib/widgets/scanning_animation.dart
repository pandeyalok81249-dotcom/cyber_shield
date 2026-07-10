import 'package:flutter/material.dart';

class ScanningAnimation extends StatefulWidget {
  final String text;

  const ScanningAnimation({
    super.key,
    this.text = "Analyzing threat patterns...",
  });

  @override
  State<ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF101722),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 90,
                    width: 90,
                    child: CircularProgressIndicator(
                      value: controller.value,
                      strokeWidth: 5,
                      color: Colors.cyanAccent,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  Transform.rotate(
                    angle: controller.value * 6.28,
                    child: const Icon(
                      Icons.radar,
                      size: 42,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Checking local rules + verified scam database",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}