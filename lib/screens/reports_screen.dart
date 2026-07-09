import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/report_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/cyber_textfield.dart';
import '../widgets/header_title.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final idController = TextEditingController();
  final detailsController = TextEditingController();
  final reportService = ReportService();

  bool submitting = false;

  Future<void> submitReport() async {
    final fraudId = idController.text.trim();
    final details = detailsController.text.trim();

    if (fraudId.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    if (details.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add more details about the fraud.")),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      await reportService.submitReport(
        fraudId: fraudId,
        details: details,
      );

      if (!mounted) return;

      idController.clear();
      detailsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fraud report submitted successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit report: $e")),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  void dispose() {
    idController.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final reportsStream = FirebaseFirestore.instance
        .collection("fraud_reports")
        .where("userId", isEqualTo: user?.uid ?? "")
        .snapshots();

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

          const SizedBox(height: 8),

          const Text(
            "Report suspicious phone numbers, emails, UPI IDs, fake websites, or scam messages.",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 18),

          CyberTextField(
            controller: idController,
            hint: "Fraud number / email / UPI ID / website",
          ),

          const SizedBox(height: 12),

          CyberTextField(
            controller: detailsController,
            hint: "Describe what happened...",
            maxLines: 5,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: submitting ? null : submitReport,
              icon: submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(submitting ? "Submitting..." : "Submit Report"),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "My Fraud Reports",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          StreamBuilder<QuerySnapshot>(
            stream: reportsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CyberCard(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const CyberCard(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text("No fraud reports submitted yet."),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final fraudId = data["fraudId"] ?? "";
                  final details = data["details"] ?? "";
                  final status = data["status"] ?? "pending_review";

                  final statusColor = status == "resolved"
                      ? Colors.greenAccent
                      : status == "rejected"
                          ? Colors.redAccent
                          : Colors.orangeAccent;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CyberCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withValues(alpha: 0.18),
                          child: Icon(Icons.report, color: statusColor),
                        ),
                        title: Text(
                          fraudId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}