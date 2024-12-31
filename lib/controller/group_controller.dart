import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GroupController extends ChangeNotifier {
  List<Map<String, dynamic>> groupList = [];

  Future<void> createGroup(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('groups').add(data);

      await fetchGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group created successfully!')),
      );
      Navigator.of(context).pop();
    } catch (error) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $error')),
      );
    }
  }

  Future<void> fetchGroups() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      groupList = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "title": data["title"],
          "description": data["description"],
          "createdAt": data["createdAt"],
          "imageUrl": data["imageUrl"],
          'user_id': data["user_id"],
          "eventType": data["eventType"],
          "offers": data["offers"],
          "location": {
              "latitude" : data["location"]["latitude"],
              "longitude" : data["location"]["longitude"]},
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching groups: $e");
    }
  }

  Future<String?> _uploadProfileImage(File? profileImage) async {
    if (profileImage == null) return null;

    try {
      String fileName =
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(profileImage);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  bool isloading = false;

  Future<void> submitForm(
    Map<String, dynamic> mapData,
    File? profileImage,
    context,
    String groupId,
  ) async {
    try {
      isloading = true;
      notifyListeners();
      String? profileImageUrl = await _uploadProfileImage(profileImage);

      mapData['profile_pic'] = profileImageUrl;

      await FirebaseFirestore.instance
          .collection('groups') // Access the 'groups' collection
          .doc(groupId)
          .collection('volunteers')
          .add(mapData);
      isloading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      isloading = false;
      notifyListeners();
      print('Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application. Try again.')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchVolunteers(String groupId) async {
    try {

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('volunteers')
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print('Error fetching volunteers: $e');
      return [];
    }
  }

}

final groupControllerNotifier =
    ChangeNotifierProvider<GroupController>((ref) => GroupController());
