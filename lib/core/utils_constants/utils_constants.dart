import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
class UtilsConstant {


  static void showSnackbarError(String message) {
    if (globalMessengerKey.currentState?.mounted == true) {
      globalMessengerKey.currentState!.hideCurrentSnackBar();

      globalMessengerKey.currentState?.showSnackBar(
        SnackBar(
          // behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static void showSnackbarSuccess(String message) {
    if (globalMessengerKey.currentState?.mounted == true) {
      globalMessengerKey.currentState!.hideCurrentSnackBar();

      globalMessengerKey.currentState?.showSnackBar(
        SnackBar(
          // behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  static String firebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'invalid-email':
        return "The email address is not valid.";
      case 'user-disabled':
        return "This user account has been disabled.";
      case 'too-many-requests':
        return "Too many attempts. Please try again later.";
      default:
        return "An unknown error occurred.";
    }
  }

 static void openGoogleMaps(LatLng location) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

 static String formatCreatedAt(dynamic createdAt) {
    String localDateTime = "";

    try {
      if (createdAt != null) {
        // Check if createdAt is a Firestore Timestamp
        if (createdAt is Timestamp) {
          DateTime dateTime = createdAt.toDate(); // Convert Timestamp to DateTime
          localDateTime = DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
        }
        // Check if createdAt is a String (ISO-8601 format)
        else if (createdAt is String) {
          DateTime dateTime = DateTime.parse(createdAt); // Parse String to DateTime
          localDateTime = DateFormat('yyyy-MM-dd hh:mm:ss').format(dateTime);
        }
      }
    } catch (e) {
      print('Error formatting createdAt: $e');
    }

    return localDateTime;
  }


}

extension StringCasingExtension on String {
  String get toCapitalized => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String get toTitleCase => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
}