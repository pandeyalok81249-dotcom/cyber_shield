import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../services/link_scanner_service.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';
import '../widgets/result_card.dart';
import '../services/history_service.dart';

class LinkScannerPage extends StatefulWidget {
  const LinkScannerPage({super.key});

  @override
  State<LinkScannerPage> createState() => _LinkScannerPageState();
}

class _LinkScannerPageState extends State<LinkScannerPage> {
  final urlController = TextEditingController();
  final scanner = LinkScannerService();
  final historyService = HistoryService();

  ScanResult? result;
  bool scanning = false;

Future<void> scanUrl() async {
  setState(() {
    scanning = true;
    result = null;
  });

  await Future.delayed(const Duration(milliseconds: 900));

  final scanResult = scanner.scan(urlController.text);

  await historyService.saveLinkScan(scanResult);

  setState(() {
    result = scanResult;
    scanning = false;
  });
}

  @override
  void dispose() {
    urlController.dispose();
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
            "Link Scanner",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            "Paste any suspicious website link and Cyber Shield will analyze its risk patterns.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          CyberTextField(
            controller: urlController,
            hint: "https://example.com",
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: scanning ? null : scanUrl,
              icon: scanning
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.link),
              label: Text(scanning ? "Scanning..." : "Scan URL"),
            ),
          ),
          const SizedBox(height: 20),
          if (result != null) ResultCard(result: result!),
        ],
      ),
    );
  }
}