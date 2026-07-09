import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController();
    final detailsController = TextEditingController();
    final reportService = ReportService();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Report Fraud",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          CyberTextField(
            controller: idController,
            hint: "Fraud number / email / UPI ID",
          ),

          const SizedBox(height: 12),

          CyberTextField(
            controller: detailsController,
            hint: "Describe what happened...",
            maxLines: 5,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () async {
              final fraudId = idController.text.trim();
              final details = detailsController.text.trim();

              if (fraudId.isEmpty || details.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields.")),
                );
                return;
              }

              try {
                await reportService.submitReport(
                  fraudId: fraudId,
                  details: details,
                );

                if (!context.mounted) return;

                idController.clear();
                detailsController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Fraud report submitted successfully."),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to submit report: $e")),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text("Submit Report"),
          ),

          const SizedBox(height: 20),

          const CyberCard(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Reports are now saved to Firestore."),
              subtitle: Text("Admin review system will be added later."),
            ),
          ),
        ],
      ),
    );
  }
}