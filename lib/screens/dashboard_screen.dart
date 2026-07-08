import 'package:flutter/material.dart';

import '../widgets/action_card.dart';
import '../widgets/header_title.dart';
import '../widgets/mini_stat.dart';
import '../widgets/security_score_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const SecurityScoreCard(),
          const SizedBox(height: 18),
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: MiniStat(title: "Threats", value: "0")),
              SizedBox(width: 12),
              Expanded(child: MiniStat(title: "Scans", value: "2")),
              SizedBox(width: 12),
              Expanded(child: MiniStat(title: "Status", value: "Safe")),
            ],
          ),
        ],
      ),
    );
  }
}