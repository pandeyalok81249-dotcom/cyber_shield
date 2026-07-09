import '../models/scan_result.dart';

class MessageScannerService {
  ScanResult scan(String message) {
    final input = message.trim();
    final lower = input.toLowerCase();

    if (input.isEmpty) {
      return const ScanResult(
        input: "",
        riskScore: 100,
        status: "Invalid",
        warnings: ["No message entered."],
        positives: [],
        advice: "Paste a suspicious SMS or WhatsApp message before scanning.",
      );
    }

    int riskScore = 0;
    final warnings = <String>[];
    final positives = <String>[];

    final scamWords = [
      "otp",
      "password",
      "pin",
      "kyc",
      "verify",
      "blocked",
      "suspended",
      "urgent",
      "click",
      "login",
      "reward",
      "cashback",
      "lottery",
      "winner",
      "gift",
      "free",
      "claim",
      "bank",
      "upi",
      "paytm",
      "phonepe",
      "account",
      "limited time",
      "expire",
      "update",
      "refund",
      "parcel",
      "delivery failed",
    ];

    int hits = 0;

    for (final word in scamWords) {
      if (lower.contains(word)) {
        hits++;
        warnings.add("Suspicious word found: $word");
      }
    }

    riskScore += (hits * 8).clamp(0, 55);

    final hasLink = RegExp(r'(http|https):\/\/|www\.').hasMatch(lower);
    if (hasLink) {
      riskScore += 22;
      warnings.add("Message contains a link.");
    } else {
      positives.add("No website link found.");
    }

    final hasPhone = RegExp(r'\b[6-9]\d{9}\b').hasMatch(input);
    if (hasPhone) {
      riskScore += 10;
      warnings.add("Message contains a phone number.");
    }

    final hasMoney = RegExp(r'(₹|rs\.?|inr|\$)\s?\d+').hasMatch(lower);
    if (hasMoney) {
      riskScore += 12;
      warnings.add("Message mentions money or reward amount.");
    }

    final asksForOtp = lower.contains("otp") ||
        lower.contains("one time password") ||
        lower.contains("verification code");

    if (asksForOtp) {
      riskScore += 28;
      warnings.add("Message asks about OTP or verification code.");
    }

    final pressureWords = [
      "immediately",
      "within 24 hours",
      "last chance",
      "final warning",
      "act now",
      "urgent",
    ];

    for (final word in pressureWords) {
      if (lower.contains(word)) {
        riskScore += 12;
        warnings.add("Uses pressure/fear language: $word");
        break;
      }
    }

    if (input.length < 25) {
      riskScore += 8;
      warnings.add("Message is very short and lacks clear details.");
    }

    if (warnings.isEmpty) {
      positives.add("No major scam pattern detected.");
    }

    riskScore = riskScore.clamp(0, 100).toInt();

    final status = riskScore < 30
        ? "Looks Safe"
        : riskScore < 70
            ? "Suspicious"
            : "High Risk";

    final advice = riskScore < 30
        ? "This message looks mostly safe, but never share OTP, PIN, or passwords."
        : riskScore < 70
            ? "This message has suspicious signs. Do not click links or share personal details."
            : "This message looks like a scam. Do not click links, do not call unknown numbers, and do not share OTP/password.";

    return ScanResult(
      input: input,
      riskScore: riskScore,
      status: status,
      warnings: warnings.toSet().toList(),
      positives: positives.toSet().toList(),
      advice: advice,
    );
  }
}