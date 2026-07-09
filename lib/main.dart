import 'package:flutter/material.dart';
import 'app.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/tips_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CyberShieldApp());
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  final pages = const [
    DashboardScreen(),
    ScannerScreen(),
    ReportsScreen(),
    TipsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: const Text("Cyber Shield"),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
    ],
  ),
  body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: const Color(0xFF101722),
        indicatorColor: Colors.cyanAccent.withValues(alpha: 0.18),
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
        side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}