import 'package:cloud_firestore/cloud_firestore.dart';

class PublicScamService {
  final _firestore = FirebaseFirestore.instance;

  String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll("https://", "")
        .replaceAll("http://", "")
        .replaceAll("www.", "")
        .replaceAll("/", "")
        .replaceAll(" ", "");
  }

  Future<Map<String, dynamic>?> checkPublicDatabase(String input) async {
    final normalized = normalize(input);

    if (normalized.isEmpty) return null;

    final result = await _firestore
        .collection("public_scam_database")
        .where("normalizedValue", isEqualTo: normalized)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    return result.docs.first.data();
  }

  Future<Map<String, dynamic>?> checkTextForPublicScam(String text) async {
    final normalizedText = normalize(text);

    if (normalizedText.isEmpty) return null;

    final result = await _firestore
        .collection("public_scam_database")
        .limit(100)
        .get();

    for (final doc in result.docs) {
      final data = doc.data();
      final normalizedValue = data["normalizedValue"] ?? "";

      if (normalizedValue.toString().isNotEmpty &&
          normalizedText.contains(normalizedValue.toString())) {
        return data;
      }
    }

    return null;
  }

  Future<void> addToPublicDatabase({
    required String value,
    required String type,
    required String reason,
    required String source,
  }) async {
    final normalized = normalize(value);

    if (normalized.isEmpty) return;

    await _firestore.collection("public_scam_database").add({
      "value": value,
      "normalizedValue": normalized,
      "type": type,
      "threatLevel": "high",
      "reason": reason,
      "source": source,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}