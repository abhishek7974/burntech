import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase_constant/firebase_constants.dart';

class CommentController extends ChangeNotifier {
  late TextEditingController commentCont = TextEditingController();
  late FocusNode commentFocusNode = FocusNode();
  bool isLoading = false;
  List<String> likedEventIds = [];

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchUserData(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  void addComment(String comment, String eventId) {
    if (comment.isEmpty) return;

    FirebaseFirestore.instance.collection("events/${eventId}/comments").add({
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': FirebaseConstants.auth.currentUser?.uid,
    });

    commentCont.clear();
    commentFocusNode.requestFocus(); // Keeps the keyboard open
    notifyListeners();
  }


  Future<void> fetchLikedPosts() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseConstants.auth.currentUser?.uid);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final likedEvents = List<String>.from(userSnapshot.data()?['liked_events'] ?? []);

        likedEventIds = likedEvents;
        isLoading = false;
      notifyListeners();

    } else {
        isLoading = false;
        notifyListeners();
    }
  }


}

final commentController =
ChangeNotifierProvider<CommentController>((ref) => CommentController());
