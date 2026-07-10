import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../services/history_service.dart';
import '../services/link_scanner_service.dart';
import '../services/public_scam_service.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';
import '../widgets/result_card.dart';
import '../widgets/scanning_animation.dart';
import '../services/threat_intelligence_service.dart';

class LinkScannerPage extends StatefulWidget {
  const LinkScannerPage({super.key});

  @override
  State<LinkScannerPage> createState() => _LinkScannerPageState();
}

class _LinkScannerPageState extends State<LinkScannerPage> {
  final urlController = TextEditingController();
  final scanner = LinkScannerService();
  final historyService = HistoryService();
  final publicScamService = PublicScamService();
  final threatService = ThreatIntelligenceService();

  ScanResult? result;
  bool scanning = false;

Future<void> scanUrl() async {
  setState(() {
    scanning = true;
    result = null;
  });

  await Future.delayed(const Duration(milliseconds: 900));

  ScanResult scanResult = scanner.scan(urlController.text);

  final threatResult = await threatService.checkUrl(urlController.text);

  if (threatResult != null && threatResult.isThreat) {
    scanResult = ScanResult(
      input: scanResult.input,
      riskScore: threatResult.riskScore,
      status: "High Risk",
      warnings: [
        "Matched real threat intelligence: ${threatResult.provider}",
        "Threat type: ${threatResult.threatType}",
        threatResult.details,
        ...scanResult.warnings,
      ],
      positives: scanResult.positives,
      advice:
          "This link matched a real threat intelligence provider. Do not open it or enter any sensitive information.",
    );
  }

  final publicMatch =
      await publicScamService.checkPublicDatabase(urlController.text);

  if (publicMatch != null) {
    final value = publicMatch["value"] ?? "Verified scam";
    final reason = publicMatch["reason"] ?? "Found in public scam database";

    scanResult = ScanResult(
      input: scanResult.input,
      riskScore: 95,
      status: "High Risk",
      warnings: [
        "Matched verified public scam database: $value",
        "Reason: $reason",
        ...scanResult.warnings,
      ],
      positives: scanResult.positives,
      advice:
          "This link is present in the verified public scam database. Do not open it, do not enter OTP/password, and report the sender.",
    );
  }

  await historyService.saveLinkScan(scanResult);

  if (!mounted) return;

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
            "Paste any suspicious website link. Cyber Shield checks phishing patterns and verified public scam database records.",
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
          if (scanning)
  const ScanningAnimation(
    text: "Scanning link for phishing and scam database match...",
  ),

if (result != null) ResultCard(result: result!),
        ],
      ),
    );
  }
}