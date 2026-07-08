import 'package:flutter/material.dart';

import '../widgets/cyber_card.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final idController = TextEditingController();
    final detailsController = TextEditingController();

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report saved locally for now.")),
              );
            },
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text("Submit Report"),
          ),
          const SizedBox(height: 20),
          const CyberCard(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Reports will connect to Firebase in next phase."),
              subtitle: Text("For now, this is UI + local demo."),
            ),
          ),
        ],
      ),
    );
  }
}