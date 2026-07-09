import '../models/scan_result.dart';

class LinkScannerService {
  ScanResult scan(String url) {
    final input = url.trim();
    final lower = input.toLowerCase();

    int riskScore = 0;
    final warnings = <String>[];
    final positives = <String>[];

    if (input.isEmpty) {
      return const ScanResult(
        input: "",
        riskScore: 100,
        status: "Invalid",
        warnings: ["No URL entered."],
        positives: [],
        advice: "Please paste a valid website link before scanning.",
      );
    }

    final uri = Uri.tryParse(input);

    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      riskScore += 35;
      warnings.add("Invalid or incomplete URL format.");
    }

    if (!lower.startsWith("https://")) {
      riskScore += 20;
      warnings.add("Website does not use HTTPS.");
    } else {
      positives.add("Uses HTTPS encryption.");
    }

    final suspiciousWords = [
      "free",
      "claim",
      "verify",
      "login",
      "bonus",
      "winner",
      "gift",
      "urgent",
      "kyc",
      "bank",
      "password",
      "otp",
    ];

    for (final word in suspiciousWords) {
      if (lower.contains(word)) {
        riskScore += 8;
        warnings.add("Contains suspicious keyword: $word");
      }
    }

    final shorteners = ["bit.ly", "tinyurl", "t.co", "goo.gl", "shorturl"];
    for (final shortener in shorteners) {
      if (lower.contains(shortener)) {
        riskScore += 25;
        warnings.add("Uses a shortened URL service.");
      }
    }

    if (uri != null && uri.host.split(".").length > 3) {
      riskScore += 12;
      warnings.add("Domain has too many subdomains.");
    }

    riskScore = riskScore.clamp(0, 100);

    final status = riskScore < 35
        ? "Looks Safe"
        : riskScore < 70
            ? "Suspicious"
            : "High Risk";

    final advice = riskScore < 35
        ? "No major phishing pattern found. Still verify the website before entering personal details."
        : riskScore < 70
            ? "This link has suspicious patterns. Avoid entering passwords, OTPs, or payment details."
            : "This link looks dangerous. Do not open it or share sensitive information.";

    return ScanResult(
      input: input,
      riskScore: riskScore,
      status: status,
      warnings: warnings,
      positives: positives,
      advice: advice,
    );
  }
}