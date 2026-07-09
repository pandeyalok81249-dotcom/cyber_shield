import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../services/history_service.dart';
import '../services/message_scanner_service.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';
import '../widgets/result_card.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final messageController = TextEditingController();
  final scanner = MessageScannerService();
  final historyService = HistoryService();

  ScanResult? result;
  bool scanning = false;

  Future<void> scanMessage() async {
    setState(() {
      scanning = true;
      result = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    final scanResult = scanner.scan(messageController.text);

    await historyService.saveMessageScan(scanResult);

    setState(() {
      result = scanResult;
      scanning = false;
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),

          const Text(
            "Message Scam Detector",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            "Paste suspicious SMS, WhatsApp, or Telegram messages. Cyber Shield will check scam patterns like OTP, fake KYC, reward, bank fraud, and phishing language.",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          CyberTextField(
            controller: messageController,
            hint: "Paste suspicious message here...",
            maxLines: 6,
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: scanning ? null : scanMessage,
              icon: scanning
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sms_outlined),
              label: Text(scanning ? "Scanning..." : "Scan Message"),
            ),
          ),

          const SizedBox(height: 20),

          if (result != null) ResultCard(result: result!),
        ],
      ),
    );
  }
}