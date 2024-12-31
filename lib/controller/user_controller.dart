import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase_constant/firebase_constants.dart';
import 'home_controller.dart';

class UserController extends ChangeNotifier {
  Map<String, dynamic>? userSnapshot;
  bool isLoading = true;

  Future<void> fetchUserProfile() async {
    try {
      final userId = FirebaseConstants.auth.currentUser?.uid;
      if (userId != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(userId);
        final snapshot = await userDoc.get();
        if (snapshot.exists) {
          userSnapshot = snapshot.data();
          isLoading = false;
          notifyListeners();
        } else {
          isLoading = false;
          notifyListeners();
        }
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');

        isLoading = false;
      notifyListeners();
    }
  }
}

final userController =
    ChangeNotifierProvider<UserController>((ref) => UserController());
