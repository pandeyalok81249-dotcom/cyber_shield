import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/cyber_card.dart';
import '../widgets/header_title.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Please login to view scan history."),
      );
    }

    final historyStream = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("scan_history")
        .orderBy("createdAt", descending: true)
        .snapshots();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Scan History",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "All your saved security scans appear here.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          StreamBuilder<QuerySnapshot>(
            stream: historyStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const CyberCard(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text("No scan history yet. Scan a link first."),
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final input = data["input"] ?? "";
                  final status = data["status"] ?? "Unknown";
                  final riskScore = data["riskScore"] ?? 0;
                  final type = data["type"] ?? "scan";

                  final color = riskScore < 35
                      ? Colors.greenAccent
                      : riskScore < 70
                          ? Colors.orangeAccent
                          : Colors.redAccent;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CyberCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.18),
                          child: Icon(Icons.security, color: color),
                        ),
                        title: Text(
                          input,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "$type • Risk Score: $riskScore/100",
                        ),
                        trailing: Text(
                          status,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
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