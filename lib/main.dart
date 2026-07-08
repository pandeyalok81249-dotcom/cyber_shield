import 'package:flutter/material.dart';

void main() {
  runApp(const CyberShieldApp());
}

class CyberShieldApp extends StatelessWidget {
  const CyberShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF070B12),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyanAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final pages = const [
    DashboardPage(),
    ScannerPage(),
    ReportsPage(),
    TipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: const Color(0xFF101722),
        indicatorColor: Colors.cyanAccent.withOpacity(0.18),
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: "Scan",
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: "Reports",
          ),
          NavigationDestination(
            icon: Icon(Icons.tips_and_updates_outlined),
            selectedIcon: Icon(Icons.tips_and_updates),
            label: "Tips",
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  final List<String> spamWords = const [
    "otp",
    "lottery",
    "winner",
    "claim",
    "free money",
    "bank blocked",
    "kyc update",
    "urgent",
    "click link",
    "loan approved",
    "upi refund",
  ];

  bool isSuspiciousText(String text) {
    final lower = text.toLowerCase();
    return spamWords.any((word) => lower.contains(word));
  }

  bool isSuspiciousLink(String link) {
    final lower = link.toLowerCase();
    return lower.contains("bit.ly") ||
        lower.contains("tinyurl") ||
        lower.contains("free") ||
        lower.contains("claim") ||
        lower.contains("login") ||
        lower.contains("verify") ||
        !lower.startsWith("https://");
  }

  @override
  Widget build(BuildContext context) {
    final smsController = TextEditingController();
    final linkController = TextEditingController();
    final numberController = TextEditingController();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Scanner Center",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ScanBox(
            title: "Message Scanner",
            hint: "Paste SMS or WhatsApp message...",
            controller: smsController,
            maxLines: 4,
            buttonText: "Scan Message",
            onScan: () {
              final result = isSuspiciousText(smsController.text);
              showResult(
                context,
                result ? "Suspicious Message" : "Looks Safe",
                result
                    ? "This message contains scam-like words. Do not share OTP or click links."
                    : "No major scam pattern found.",
              );
            },
          ),
          const SizedBox(height: 16),
          ScanBox(
            title: "Phishing Link Scanner",
            hint: "Paste website link...",
            controller: linkController,
            buttonText: "Scan Link",
            onScan: () {
              final result = isSuspiciousLink(linkController.text);
              showResult(
                context,
                result ? "Risky Link" : "Link Looks Safer",
                result
                    ? "This link has risky patterns. Avoid opening it."
                    : "No obvious phishing pattern found.",
              );
            },
          ),
          const SizedBox(height: 16),
          ScanBox(
            title: "Suspicious Number Checker",
            hint: "Enter phone number...",
            controller: numberController,
            buttonText: "Check Number",
            onScan: () {
              final number = numberController.text.trim();
              final risky = number.length < 10 ||
                  number.startsWith("+92") ||
                  number.startsWith("140");

              showResult(
                context,
                risky ? "Suspicious Number" : "Number Looks Normal",
                risky
                    ? "This number looks unusual. Be careful before calling back."
                    : "No basic suspicious pattern found.",
              );
            },
          ),
        ],
      ),
    );
  }

  void showResult(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF101722),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  final tips = const [
    "Never share OTP, UPI PIN, or bank password.",
    "Do not install APK files from unknown sources.",
    "Check website spelling before login.",
    "Banks never ask for OTP on call.",
    "Avoid links saying lottery, free money, urgent KYC.",
    "Use 2-factor authentication on important accounts.",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const HeaderTitle(),
          const SizedBox(height: 20),
          const Text(
            "Security Tips",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CyberCard(
                child: ListTile(
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(tip),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.shield, size: 34, color: Colors.cyanAccent),
        SizedBox(width: 10),
        Text(
          "Cyber Shield",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class SecurityScoreCard extends StatelessWidget {
  const SecurityScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Security Score", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              "96/100",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: 0.96,
                minHeight: 12,
                backgroundColor: Colors.white12,
                color: Colors.cyanAccent,
              ),
            ),
            const SizedBox(height: 12),
            const Text("Your device looks protected in basic checks."),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: Colors.cyanAccent),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const MiniStat({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanBox extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final String buttonText;
  final VoidCallback onScan;

  const ScanBox({
    super.key,
    required this.title,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    required this.buttonText,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CyberTextField(
              controller: controller,
              hint: hint,
              maxLines: maxLines,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onScan,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CyberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const CyberTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF0B111A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class CyberCard extends StatelessWidget {
  final Widget child;

  const CyberCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF101722),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.cyanAccent.withOpacity(0.12)),
      ),
      child: child,
    );
  }
}