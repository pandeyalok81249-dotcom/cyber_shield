import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> clearScanHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final scans = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("scan_history")
        .get();

    for (final doc in scans.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> clearMyFraudReports() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reports = await _firestore
        .collection("fraud_reports")
        .where("userId", isEqualTo: user.uid)
        .get();

    for (final doc in reports.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteAccountAndData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    await clearScanHistory();
    await clearMyFraudReports();

    await _firestore.collection("users").doc(uid).delete();

    await user.delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}