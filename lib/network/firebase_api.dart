import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAPI {
  final _firestore = FirebaseFirestore.instance;
  Stream getMessage() {
    return _firestore
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
