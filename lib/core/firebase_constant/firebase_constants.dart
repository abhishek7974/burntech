import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConstants {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static String? cUId = (auth.currentUser?.uid ?? "");
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

 static Future<Map<String, dynamic>?> getCurrentUser({String? userId}) async {
    if (auth.currentUser?.uid == null) {

      return null;
    }
    DocumentSnapshot<Map<String, dynamic>> snapshot =
    await firestore.collection("users").doc(userId ?? auth.currentUser!.uid).get();

    return snapshot.data();
  }
}
