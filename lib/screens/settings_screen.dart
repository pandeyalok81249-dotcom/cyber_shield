import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../widgets/cyber_card.dart';
import '../widgets/header_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settingsService = SettingsService();
  bool loading = false;

  Future<void> clearHistory() async {
    setState(() => loading = true);

    try {
      await settingsService.clearScanHistory();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan history cleared successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear history: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> clearReports() async {
    setState(() => loading = true);

    try {
      await settingsService.clearMyFraudReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fraud reports cleared successfully.")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to clear reports: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteAccount() async {
    setState(() => loading = true);

    try {
      await settingsService.deleteAccountAndData();

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account deleted successfully.")),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = e.code == "requires-recent-login"
          ? "For security, please logout and login again before deleting your account."
          : "Failed to delete account: ${e.message}";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete account: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> confirmClearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear scan history?"),
          content: const Text(
            "This will permanently delete your saved scan history.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await clearHistory();
    }
  }

  Future<void> confirmClearReports() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear fraud reports?"),
          content: const Text(
            "This will permanently delete your submitted fraud reports from your account.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Clear"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await clearReports();
    }
  }

  Future<void> confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete account permanently?"),
          content: const Text(
            "This will delete your account, scan history, fraud reports, and profile data. This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Privacy"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const HeaderTitle(),
            const SizedBox(height: 20),

            const Text(
              "Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            CyberCard(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(user?.email ?? "No email found"),
                subtitle: const Text("Signed in account"),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Privacy Controls",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            CyberCard(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Clear Scan History"),
                subtitle: const Text("Delete all saved link and message scans."),
                trailing: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: loading ? null : confirmClearHistory,
              ),
            ),

            const SizedBox(height: 12),

            CyberCard(
              child: ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text("Clear Fraud Reports"),
                subtitle: const Text("Delete reports submitted from your account."),
                trailing: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: loading ? null : confirmClearReports,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Danger Zone",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),

            const SizedBox(height: 12),

            CyberCard(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  "Delete Account",
                  style: TextStyle(color: Colors.redAccent),
                ),
                subtitle: const Text(
                  "Permanently delete your account and all saved data.",
                ),
                trailing: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: loading ? null : confirmDeleteAccount,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Safety Note",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const CyberCard(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  "Cyber Shield helps detect scam patterns, but always verify links, messages, and callers before sharing OTP, PIN, passwords, or payment details.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}