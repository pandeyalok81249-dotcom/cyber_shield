import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/action_card.dart';
import '../widgets/cyber_card.dart';
import '../widgets/header_title.dart';
import '../widgets/mini_stat.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("Please login to view dashboard."),
      );
    }

    final scanStream = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("scan_history")
        .orderBy("createdAt", descending: true)
        .snapshots();

    final reportStream = FirebaseFirestore.instance
        .collection("fraud_reports")
        .where("userId", isEqualTo: user.uid)
        .snapshots();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),

          StreamBuilder<QuerySnapshot>(
            stream: scanStream,
            builder: (context, scanSnapshot) {
              if (scanSnapshot.connectionState == ConnectionState.waiting) {
                return const CyberCard(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final scanDocs = scanSnapshot.data?.docs ?? [];

              final totalScans = scanDocs.length;

              final highRiskScans = scanDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final riskScore = data["riskScore"] ?? 0;
                return riskScore >= 70;
              }).length;

              final suspiciousScans = scanDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final riskScore = data["riskScore"] ?? 0;
                return riskScore >= 35 && riskScore < 70;
              }).length;

              final averageRisk = totalScans == 0
                  ? 0
                  : scanDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["riskScore"] ?? 0;
                    }).reduce((a, b) => a + b) ~/
                      totalScans;

              final securityScore = (100 - averageRisk).clamp(0, 100).toInt();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardSecurityScore(
                    score: securityScore,
                    totalScans: totalScans,
                    highRiskScans: highRiskScans,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: const [
                      ActionCard(
                        icon: Icons.sms_outlined,
                        title: "Message Scan",
                        subtitle: "Detect scam SMS",
                      ),
                      ActionCard(
                        icon: Icons.link_outlined,
                        title: "Link Scan",
                        subtitle: "Find phishing links",
                      ),
                      ActionCard(
                        icon: Icons.phone_android,
                        title: "Number Check",
                        subtitle: "Check spam callers",
                      ),
                      ActionCard(
                        icon: Icons.privacy_tip_outlined,
                        title: "Permission Check",
                        subtitle: "Coming soon",
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Today's Security",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: reportStream,
                    builder: (context, reportSnapshot) {
                      final reportCount = reportSnapshot.data?.docs.length ?? 0;

                      return Row(
                        children: [
                          Expanded(
                            child: MiniStat(
                              title: "Scans",
                              value: "$totalScans",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MiniStat(
                              title: "High Risk",
                              value: "$highRiskScans",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MiniStat(
                              title: "Reports",
                              value: "$reportCount",
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Risk Breakdown",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: MiniStat(
                          title: "Safe",
                          value:
                              "${totalScans - highRiskScans - suspiciousScans}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MiniStat(
                          title: "Suspicious",
                          value: "$suspiciousScans",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MiniStat(
                          title: "Avg Risk",
                          value: "$averageRisk%",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Latest Activity",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  if (scanDocs.isEmpty)
                    const CyberCard(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text("No scans yet. Scan a link to see activity."),
                      ),
                    )
                  else
                    ...scanDocs.take(5).map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final input = data["input"] ?? "";
                      final status = data["status"] ?? "Unknown";
                      final riskScore = data["riskScore"] ?? 0;

                      final color = riskScore < 35
                          ? Colors.greenAccent
                          : riskScore < 70
                              ? Colors.orangeAccent
                              : Colors.redAccent;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CyberCard(
                          child: ListTile(
                            leading: Icon(Icons.security, color: color),
                            title: Text(
                              input,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text("Risk Score: $riskScore/100"),
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
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardSecurityScore extends StatelessWidget {
  final int score;
  final int totalScans;
  final int highRiskScans;

  const DashboardSecurityScore({
    super.key,
    required this.score,
    required this.totalScans,
    required this.highRiskScans,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 75
        ? Colors.greenAccent
        : score >= 45
            ? Colors.orangeAccent
            : Colors.redAccent;

    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Live Security Score", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(
              "$score/100",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 12,
                backgroundColor: Colors.white12,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              totalScans == 0
                  ? "Start scanning links to calculate your live security score."
                  : highRiskScans == 0
                      ? "No high-risk scans found. Your activity looks safe."
                      : "$highRiskScans high-risk scan detected. Review your history.",
            ),
          ],
        ),
      ),
    );
  }
}