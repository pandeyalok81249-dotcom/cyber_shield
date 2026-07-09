import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/scan_result.dart';

class HistoryService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> saveLinkScan(ScanResult result) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("scan_history")
        .add({
      "type": "link",
      "input": result.input,
      "riskScore": result.riskScore,
      "status": result.status,
      "warnings": result.warnings,
      "positives": result.positives,
      "advice": result.advice,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}