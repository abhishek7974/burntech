import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/view/admin_view/admin_nav/admin_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils_constants/utils_constants.dart';
import '../core/utils_constants/utils_constants.dart';
import '../view/user_view/bottom_nav_bar/bottom_nav_bar.dart';

class LoginController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  bool emailValidator(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
  }

  Future<void> validateAndLogin(
      BuildContext context, String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseConstants.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        if (userCredential.user?.email?.toLowerCase() == "abhishek@gmail.com") {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminBottomBar()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BottomNavBar()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      UtilsConstant.showSnackbarError(
        UtilsConstant.firebaseAuthError(e.code),
      );
    } catch (e) {
      UtilsConstant.showSnackbarError("An error occurred. Please try again.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signupUser(
    BuildContext context,
    String email,
    String name,
    String password,
  ) async {

    isLoading = true;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseConstants.auth.createUserWithEmailAndPassword(
        email: email,
        password: email,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': name,
          'email': password,
        });
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => BottomNavBar()),
              (route) => false,
        );
        return null; // Signup successful
      }
    } on FirebaseAuthException catch (e) {
       UtilsConstant.firebaseAuthError(e.code);
    } catch (e) {
      UtilsConstant.firebaseAuthError("An error occurred. Please try again.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    UtilsConstant.firebaseAuthError("Unknown error occurred.");
  }
}

final loginProvider = ChangeNotifierProvider<LoginController>((ref) {
  return LoginController();
});
