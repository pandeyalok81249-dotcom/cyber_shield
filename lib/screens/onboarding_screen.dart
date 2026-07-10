import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pageController = PageController();
  int currentPage = 0;

  final pages = const [
    _OnboardItem(
      icon: Icons.link,
      title: "Detect Phishing Links",
      subtitle:
          "Scan suspicious links before opening them and avoid fake login, bank, KYC, reward, and OTP scams.",
    ),
    _OnboardItem(
      icon: Icons.sms_outlined,
      title: "Check Scam Messages",
      subtitle:
          "Paste SMS, WhatsApp, or Telegram messages and Cyber Shield will detect scam patterns instantly.",
    ),
    _OnboardItem(
      icon: Icons.public,
      title: "Community Scam Database",
      subtitle:
          "Verified reports help protect other users from known scam numbers, emails, UPI IDs, and websites.",
    ),
    _OnboardItem(
      icon: Icons.privacy_tip_outlined,
      title: "Privacy First",
      subtitle:
          "Your scan history, reports, and account data stay protected with clear privacy controls.",
    ),
  ];

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_done", true);

    if (!mounted) return;

    widget.onFinished();
  }

  void nextPage() {
    if (currentPage == pages.length - 1) {
      finishOnboarding();
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const _AnimatedGlowBackground(),

            PageView.builder(
              controller: pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = pages[index];

                return Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: Colors.cyanAccent,
                                size: 30,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Cyber Shield",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: finishOnboarding,
                            child: const Text("Skip"),
                          ),
                        ],
                      ),

                      const Spacer(),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey(item.icon),
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyanAccent.withValues(alpha: 0.10),
                            border: Border.all(
                              color: Colors.cyanAccent.withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.cyanAccent.withValues(alpha: 0.18),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            size: 78,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          item.title,
                          key: ValueKey(item.title),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: Text(
                          item.subtitle,
                          key: ValueKey(item.subtitle),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: currentPage == index ? 28 : 8,
                            decoration: BoxDecoration(
                              color: currentPage == index
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
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: nextPage,
                          icon: Icon(
                            isLast
                                ? Icons.verified_user_outlined
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            isLast ? "Start Protection" : "Continue",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedGlowBackground extends StatefulWidget {
  const _AnimatedGlowBackground();

  @override
  State<_AnimatedGlowBackground> createState() =>
      _AnimatedGlowBackgroundState();
}

class _AnimatedGlowBackgroundState extends State<_AnimatedGlowBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = controller.value;

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.6 + value * 1.2, -0.8 + value * 0.4),
              radius: 1.2,
              colors: [
                Colors.cyanAccent.withValues(alpha: 0.16),
                const Color(0xFF070B12),
                const Color(0xFF05070D),
              ],
            ),
          ),
        );
      },
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