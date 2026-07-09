class ScanResult {
  final String input;
  final int riskScore;
  final String status;
  final List<String> warnings;
  final List<String> positives;
  final String advice;

  const ScanResult({
    required this.input,
    required this.riskScore,
    required this.status,
    required this.warnings,
    required this.positives,
    required this.advice,
  });

  bool get isSafe => riskScore < 35;
  bool get isWarning => riskScore >= 35 && riskScore < 70;
  bool get isDanger => riskScore >= 70;
}