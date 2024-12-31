import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchController extends ChangeNotifier {
  List<Map<String, dynamic>> allLocations = [];
  List<Map<String, dynamic>> filteredLocations = [];

  // Fetch all locations from Firestore
  Future<void> loadAllLocations() async {
    try {
      final querySnapshot =
      await FirebaseFirestore.instance.collection('events').get();

      allLocations = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id" : doc.id,
          "events_type": data["events_type"],
          "image_url": data["image_url"],
          "location": data["location"],
          "time": data["time"],
          "title": data["title"],
          "description": data["description"],
        };
      }).toList();

    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  // Search locations based on query
  void searchLocations(String query) {
    if (query.isEmpty) {
      filteredLocations = [];
    } else {
      filteredLocations = allLocations.where((location) {
        final title = location['title']?.toString().toLowerCase() ?? '';

        return title.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }


}

final searchControllerProvider = ChangeNotifierProvider((ref) {
  return SearchController();
});
