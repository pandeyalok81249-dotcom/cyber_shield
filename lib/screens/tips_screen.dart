import 'package:flutter/material.dart';

import '../widgets/cyber_card.dart';
import '../widgets/header_title.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  final tips = const [
    "Never share OTP, UPI PIN, or bank password.",
    "Do not install APK files from unknown sources.",
    "Check website spelling before login.",
    "Banks never ask for OTP on call.",
    "Avoid links saying lottery, free money, urgent KYC.",
    "Use 2-factor authentication on important accounts.",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Security Tips",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CyberCard(
                child: ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(tip),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}