import 'dart:convert';

import 'package:http/http.dart' as http;

class ThreatIntelligenceResult {
  final bool isThreat;
  final String provider;
  final String threatType;
  final int riskScore;
  final String details;

  const ThreatIntelligenceResult({
    required this.isThreat,
    required this.provider,
    required this.threatType,
    required this.riskScore,
    required this.details,
  });

  factory ThreatIntelligenceResult.fromJson(Map<String, dynamic> json) {
    return ThreatIntelligenceResult(
      isThreat: json["isThreat"] == true,
      provider: json["provider"]?.toString() ?? "Threat Intelligence",
      threatType: json["threatType"]?.toString() ?? "unknown",
      riskScore: json["riskScore"] is int ? json["riskScore"] : 0,
      details: json["details"]?.toString() ?? "No details available.",
    );
  }
}

class ThreatIntelligenceService {
  // Later we will put your backend URL here.
  // Example backend response:
  // {
  //   "isThreat": true,
  //   "provider": "Google Safe Browsing",
  //   "threatType": "SOCIAL_ENGINEERING",
  //   "riskScore": 98,
  //   "details": "URL matched phishing/malware threat database."
  // }

  static const String backendEndpoint = "";

  bool get isConfigured => backendEndpoint.trim().isNotEmpty;

  Future<ThreatIntelligenceResult?> checkUrl(String url) async {
    if (!isConfigured) return null;

    try {
      final response = await http
          .post(
            Uri.parse(backendEndpoint),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "url": url.trim(),
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return ThreatIntelligenceResult.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}