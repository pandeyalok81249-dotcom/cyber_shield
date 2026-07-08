import 'package:flutter/material.dart';

import '../widgets/cyber_card.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  final List<String> spamWords = const [
    "otp",
    "lottery",
    "winner",
    "claim",
    "free money",
    "bank blocked",
    "kyc update",
    "urgent",
    "click link",
    "loan approved",
    "upi refund",
  ];

  bool isSuspiciousText(String text) {
    final lower = text.toLowerCase();
    return spamWords.any((word) => lower.contains(word));
  }

  bool isSuspiciousLink(String link) {
    final lower = link.toLowerCase();
    return lower.contains("bit.ly") ||
        lower.contains("tinyurl") ||
        lower.contains("free") ||
        lower.contains("claim") ||
        lower.contains("login") ||
        lower.contains("verify") ||
        !lower.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    final smsController = TextEditingController();
    final linkController = TextEditingController();
    final numberController = TextEditingController();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Scanner Center",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ScanBox(
            title: "Message Scanner",
            hint: "Paste SMS or WhatsApp message...",
            controller: smsController,
            maxLines: 4,
            buttonText: "Scan Message",
            onScan: () {
              final result = isSuspiciousText(smsController.text);
              showResult(
                context,
                result ? "Suspicious Message" : "Looks Safe",
                result
                    ? "This message contains scam-like words. Do not share OTP or click links."
                    : "No major scam pattern found.",
              );
            },
          ),

          const SizedBox(height: 16),

          ScanBox(
            title: "Phishing Link Scanner",
            hint: "Paste website link...",
            controller: linkController,
            buttonText: "Scan Link",
            onScan: () {
              final result = isSuspiciousLink(linkController.text);
              showResult(
                context,
                result ? "Risky Link" : "Link Looks Safer",
                result
                    ? "This link has risky patterns. Avoid opening it."
                    : "No obvious phishing pattern found.",
              );
            },
          ),

          const SizedBox(height: 16),

          ScanBox(
            title: "Suspicious Number Checker",
            hint: "Enter phone number...",
            controller: numberController,
            buttonText: "Check Number",
            onScan: () {
              final number = numberController.text.trim();
              final risky = number.length < 10 ||
                  number.startsWith("+92") ||
                  number.startsWith("140");

              showResult(
                context,
                risky ? "Suspicious Number" : "Number Looks Normal",
                risky
                    ? "This number looks unusual. Be careful before calling back."
                    : "No basic suspicious pattern found.",
              );
            },
          ),
        ],
      ),
    );
  }

  void showResult(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101722),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class ScanBox extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final String buttonText;
  final VoidCallback onScan;

  const ScanBox({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    required this.buttonText,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CyberTextField(
              controller: controller,
              hint: hint,
              maxLines: maxLines,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onScan,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}