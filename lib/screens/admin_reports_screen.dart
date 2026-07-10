import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/cyber_card.dart';
import '../widgets/header_title.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  bool get isAdmin {
    final email = FirebaseAuth.instance.currentUser?.email;
    return email == "pandeyalok81240@gmail.com";
  }

  Future<void> updateStatus(String reportId, String status) async {
    await FirebaseFirestore.instance
        .collection("fraud_reports")
        .doc(reportId)
        .update({
      "status": status,
      "reviewedAt": FieldValue.serverTimestamp(),
    });
  }

  Color statusColor(String status) {
    if (status == "resolved") return Colors.greenAccent;
    if (status == "rejected") return Colors.redAccent;
    return Colors.orangeAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text("Access denied. Admin only."),
        ),
      );
    }

    final reportsStream = FirebaseFirestore.instance
        .collection("fraud_reports")
        .orderBy("createdAt", descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Review Panel"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const HeaderTitle(),
            const SizedBox(height: 20),

            const Text(
              "Fraud Reports Review",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Review user-submitted fraud reports and update their status.",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 18),

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
                      child: Text("No fraud reports found."),
                    ),
                  );
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final fraudId = data["fraudId"] ?? "";
                    final details = data["details"] ?? "";
                    final status = data["status"] ?? "pending_review";
                    final userEmail = data["userEmail"] ?? "Unknown user";

                    final color = statusColor(status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: CyberCard(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        color.withValues(alpha: 0.18),
                                    child: Icon(Icons.report, color: color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      fraudId,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "Reported by: $userEmail",
                                style: const TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                details,
                                style: const TextStyle(height: 1.4),
                              ),

                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await updateStatus(
                                          doc.id,
                                          "pending_review",
                                        );
                                      },
                                      child: const Text("Pending"),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await updateStatus(
                                          doc.id,
                                          "resolved",
                                        );
                                      },
                                      child: const Text("Resolved"),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () async {
                                        await updateStatus(
                                          doc.id,
                                          "rejected",
                                        );
                                      },
                                      child: const Text("Reject"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}