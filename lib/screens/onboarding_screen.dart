import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OnboardingScreen extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);
    onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardItem(
        icon: Icons.link,
        title: "Detect Phishing Links",
        subtitle:
            "Scan suspicious links before opening them and avoid fake login, bank, KYC, and reward scams.",
      ),
      _OnboardItem(
        icon: Icons.sms_outlined,
        title: "Check Scam Messages",
        subtitle:
            "Paste SMS, WhatsApp, or Telegram messages and Cyber Shield will detect scam patterns.",
      ),
      _OnboardItem(
        icon: Icons.privacy_tip_outlined,
        title: "Protect Your Data",
        subtitle:
            "Your scan history and reports stay inside your account with privacy controls.",
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final item = pages[index];

            return Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const Icon(
                    Icons.security,
                    size: 72,
                    color: Colors.cyanAccent,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Cyber Shield",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Fraud & Scam Protection",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),

                  const Spacer(),

                  Icon(
                    item.icon,
                    size: 92,
                    color: Colors.cyanAccent,
                  ),

                  const SizedBox(height: 28),

                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (dotIndex) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: index == dotIndex ? 24 : 8,
                        decoration: BoxDecoration(
                          color: index == dotIndex
                              ? Colors.cyanAccent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (index == pages.length - 1) {
                          finishOnboarding();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Swipe left to continue."),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        index == pages.length - 1
                            ? "Get Started"
                            : "Continue",
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}