import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitReport({
    required String fraudId,
    required String details,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    await _firestore.collection("fraud_reports").add({
      "userId": user.uid,
      "userEmail": user.email,
      "fraudId": fraudId,
      "details": details,
      "status": "pending_review",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}