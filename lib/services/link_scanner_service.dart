import '../models/scan_result.dart';

class LinkScannerService {
  ScanResult scan(String url) {
    final rawInput = url.trim();

    if (rawInput.isEmpty) {
      return const ScanResult(
        input: "",
        riskScore: 100,
        status: "Invalid",
        warnings: ["No URL entered."],
        positives: [],
        advice: "Please paste a valid website link before scanning.",
      );
    }

    final normalizedInput = rawInput.startsWith("http://") ||
            rawInput.startsWith("https://")
        ? rawInput
        : "https://$rawInput";

    final lower = normalizedInput.toLowerCase();
    final uri = Uri.tryParse(normalizedInput);

    int riskScore = 0;
    final warnings = <String>[];
    final positives = <String>[];

    if (uri == null || uri.host.isEmpty) {
      return ScanResult(
        input: rawInput,
        riskScore: 100,
        status: "Invalid",
        warnings: const ["Invalid or incomplete URL format."],
        positives: const [],
        advice: "This link format is invalid. Do not open it.",
      );
    }

    final host = uri.host.toLowerCase();
    final fullDomainParts = host.split(".");
    

    bool hostMatches(String domain) {
      return host == domain || host.endsWith(".$domain");
    }

    // Basic safety checks
    if (rawInput != normalizedInput) {
      riskScore += 5;
      warnings.add("No protocol was added, analyzed as HTTPS.");
    }

    if (uri.scheme != "https") {
      riskScore += 22;
      warnings.add("Website does not use HTTPS.");
    } else {
      positives.add("Uses HTTPS encryption.");
    }

    if (uri.userInfo.isNotEmpty) {
      riskScore += 35;
      warnings.add("URL contains hidden user-info section, often used in phishing.");
    }

    if (host.contains("xn--")) {
      riskScore += 30;
      warnings.add("Domain uses punycode, which can imitate real brand names.");
    }

    final ipPattern = RegExp(r'^\d{1,3}(\.\d{1,3}){3}$');
    if (ipPattern.hasMatch(host)) {
      riskScore += 30;
      warnings.add("Website uses an IP address instead of a normal domain.");
    }

    if (fullDomainParts.length > 3) {
      riskScore += 12;
      warnings.add("Domain has too many subdomains.");
    }

    final hyphenCount = "-".allMatches(host).length;
    if (hyphenCount >= 3) {
      riskScore += 16;
      warnings.add("Domain has too many hyphens.");
    }

    if (host.length > 45) {
      riskScore += 14;
      warnings.add("Domain name is unusually long.");
    }

    // Suspicious words
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
      "reward",
      "cashback",
      "limited",
      "unlock",
      "blocked",
      "suspend",
      "account",
      "update",
    ];

    int keywordHits = 0;

    for (final word in suspiciousWords) {
      if (lower.contains(word)) {
        keywordHits++;
        warnings.add("Contains suspicious keyword: $word");
      }
    }

    riskScore += (keywordHits * 7).clamp(0, 35);

    // URL shorteners
    final shorteners = [
      "bit.ly",
      "tinyurl.com",
      "t.co",
      "goo.gl",
      "shorturl.at",
      "cutt.ly",
      "is.gd",
      "rebrand.ly",
    ];

    for (final shortener in shorteners) {
      if (hostMatches(shortener)) {
        riskScore += 28;
        warnings.add("Uses a shortened URL service.");
        break;
      }
    }

    // Suspicious TLDs
    final riskyTlds = [
      "zip",
      "mov",
      "xyz",
      "top",
      "click",
      "work",
      "loan",
      "gq",
      "tk",
      "ml",
    ];

    final tld = fullDomainParts.last;
    if (riskyTlds.contains(tld)) {
      riskScore += 15;
      warnings.add("Uses a domain extension often abused in scam links: .$tld");
    }

    // Redirect tricks
    final redirectWords = [
      "redirect",
      "return",
      "next",
      "url=",
      "target=",
      "continue=",
    ];

    for (final word in redirectWords) {
      if (lower.contains(word)) {
        riskScore += 10;
        warnings.add("URL may contain redirect behavior.");
        break;
      }
    }

    // Brand impersonation checks
    final officialDomains = {
      "google": ["google.com"],
      "gmail": ["google.com", "gmail.com"],
      "facebook": ["facebook.com"],
      "instagram": ["instagram.com"],
      "whatsapp": ["whatsapp.com", "wa.me"],
      "amazon": ["amazon.in", "amazon.com"],
      "flipkart": ["flipkart.com"],
      "paytm": ["paytm.com", "paytm.in"],
      "phonepe": ["phonepe.com"],
      "sbi": ["sbi.co.in", "onlinesbi.sbi"],
      "hdfc": ["hdfcbank.com"],
      "icici": ["icicibank.com"],
      "axis": ["axisbank.com"],
    };

    officialDomains.forEach((brand, domains) {
      final containsBrand = lower.contains(brand);
      final isOfficial = domains.any(hostMatches);

      if (containsBrand && !isOfficial) {
        riskScore += 18;
        warnings.add("Possible $brand brand impersonation.");
      }
    });

    // Known safe domains for demo/testing
    final trustedDomains = [
      "google.com",
      "flutter.dev",
      "firebase.google.com",
      "github.com",
      "microsoft.com",
      "apple.com",
    ];

    if (trustedDomains.any(hostMatches)) {
      positives.add("Domain is commonly trusted.");
      riskScore -= 10;
    }

    if (warnings.isEmpty) {
      positives.add("No major phishing pattern detected.");
    }

    riskScore = riskScore.clamp(0, 100).toInt();

    final status = riskScore < 30
        ? "Looks Safe"
        : riskScore < 70
            ? "Suspicious"
            : "High Risk";

    final advice = riskScore < 30
        ? "This link looks safe based on local checks. Still verify before entering passwords, OTPs, or payment details."
        : riskScore < 70
            ? "This link has suspicious patterns. Avoid entering sensitive information unless you fully trust the source."
            : "This link looks dangerous. Do not open it, do not enter OTP/password, and report it if someone sent it to you.";

    return ScanResult(
      input: rawInput,
      riskScore: riskScore,
      status: status,
      warnings: warnings.toSet().toList(),
      positives: positives.toSet().toList(),
      advice: advice,
    );
  }
}