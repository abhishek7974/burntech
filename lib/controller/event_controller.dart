
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/firebase_constant/firebase_constants.dart';
import '../models/event_model.dart';

class EventController extends ChangeNotifier {
  final EventModel _model = EventModel();

  bool isLoading = false;
  bool isLiked = false;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> finalEvents = [];

  Future<String> uploadImage(File imageFile) async {
    isLoading = true;
    notifyListeners();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef =
        FirebaseStorage.instance.ref().child('event_images/$fileName');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveEvent({
    required String title,
    required String description,
    required String imageUrl,
    required String eventType,
    required String time,
    required LatLng location,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      await FirebaseFirestore.instance.collection('events').add({
        'user_id' : FirebaseConstants.cUId,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'events_type': eventType,
        'time': time,
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },
      });

     await fetchEvents(
        eventType: eventType,
        isSearching: false,
        searchQuery: '',
      );
    } catch (e) {
      print("smoething went wrnog");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLikedStatus(String eventId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseConstants.cUId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final likedEvents =
          List<String>.from(userSnapshot.data()?['liked_events'] ?? []);

      isLiked = likedEvents.contains(eventId);
      notifyListeners();
    }
  }

  void likePost(String eventId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseConstants.cUId);
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final likedEvents =
          List<String>.from(userSnapshot.data()?['liked_events'] ?? []);

      if (!likedEvents.contains(eventId)) {
        likedEvents.add(eventId);
        await userDoc
            .set({'liked_events': likedEvents}, SetOptions(merge: true));
        isLiked = true;
        notifyListeners();
      } else {
        likedEvents.remove(eventId);
        await userDoc
            .set({'liked_events': likedEvents}, SetOptions(merge: true));
        isLiked = false;
        notifyListeners();
      }
    }
  }



  bool hasError = false;

  Future<void> fetchEvents({
    required String? eventType,
    required String? searchQuery,
    required bool isSearching,
  }) async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot;

      querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('events_type', isEqualTo: eventType ?? 'events').get();

      finalEvents = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {

          "id": doc.id,
          "events_type": data["events_type"],
          "image_url": data["image_url"],
          "location": data["location"],
          "time": data["time"],
          "title": data["title"],
          "description": data["description"],
        };
      }).toList();
      if (isSearching && (searchQuery ?? "").isNotEmpty) {
        events = finalEvents.where((location) {
          final title = location['title']?.toString().toLowerCase() ?? '';
          return title.contains(searchQuery!.toLowerCase());
        }).toList();
        notifyListeners();
      } else {
        events = finalEvents;
        notifyListeners();
      }
    } catch (e) {
      hasError = true;
      print('Error fetching events: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void getFilter(List<String> filters) {
    final now = DateTime.now();
    DateTime startDate = now;
    DateTime endDate = now;

    if (filters.contains("Today")) {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    events = finalEvents.where((location) {
      DateTime eventTime = DateTime.parse(location['time']);

      bool matchesTime =
          !filters.contains("Today") || (eventTime.isAfter(startDate) && eventTime.isBefore(endDate));

      bool matchesType = true;
      if (filters.contains("Nearest")) {
        // You can implement logic to sort by nearest location if latitude/longitude is available.
      }

      bool matchesLikes = true; // Implement logic to sort/filter by likes if needed.

      return matchesTime && matchesType && matchesLikes;
    }).toList();

    notifyListeners();
  }

  Future<Map<String, dynamic>?> calculateTravelTimes(LatLng latLng) async {
    try {

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      LatLng currentLocation = LatLng(40.7864, -119.2065);

      print(
          "current Location ${currentLocation.longitude + currentLocation.longitude}");
      final times = await getTravelTimes(
        currentLocation,
        latLng,
        "AIzaSyBQ8YNTVrh7FXmAkttnDNhdjTqm4Inynko",
      );
      print("Time +++ $times");


      return {
        'walking': _formatDuration(int.parse(times['walking'].toString())),
        'bicycling': _formatDuration(int.parse(times['bicycling'].toString())),
      };
    } catch (e) {
      print("Error calculating travel times: $e");
      return null;
    }
  }

  String _formatDuration(int durationInSeconds) {
    int days = durationInSeconds ~/ (24 * 3600);
    int hours = (durationInSeconds % (24 * 3600)) ~/ 3600;
    int minutes = (durationInSeconds % 3600) ~/ 60;

    String formattedDuration = '';
    if (days > 0) formattedDuration += '${days}d ';
    if (hours > 0) formattedDuration += '${hours}h ';
    if (minutes > 0) formattedDuration += '${minutes}m';

    return formattedDuration.trim();
  }


  Future<Map<String, int>> getTravelTimes(
      LatLng origin, LatLng destination, String apiKey) async {
    final baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    final originParam = '${origin.latitude},${origin.longitude}';
    final destinationParam = '${destination.latitude},${destination.longitude}';

    try {
      // Walking
      final walkingUrl =
          '$baseUrl?origin=$originParam&destination=$destinationParam&mode=walking&key=$apiKey';
      final walkingResponse = await http.get(Uri.parse(walkingUrl));

      // Bicycling
      final bicyclingUrl =
          '$baseUrl?origin=$originParam&destination=$destinationParam&mode=bicycling&key=$apiKey';
      final bicyclingResponse = await http.get(Uri.parse(bicyclingUrl));

      if (walkingResponse.statusCode == 200 &&
          bicyclingResponse.statusCode == 200) {
        final walkingData = json.decode(walkingResponse.body);
        final bicyclingData = json.decode(bicyclingResponse.body);

        final walkingDuration = walkingData['routes'][0]['legs'][0]['duration']
        ['value']; // duration in seconds
        final bicyclingDuration = bicyclingData['routes'][0]['legs'][0]
        ['duration']['value']; // duration in seconds

        return {
          'walking': walkingDuration,
          'bicycling': bicyclingDuration,
        };
      } else {
        throw Exception('Failed to fetch travel times');
      }
    } catch (e) {
      print("Error fetching travel times: $e");
      throw e;
    }
  }

  bool _isLoading = false;
  bool get isLoadingUpdate => _isLoading;


  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String time,
    required Map<String, double> location,
    File? imageFile,
    String? existingImageUrl,
    required BuildContext context,
  }) async {
    if (title.isEmpty || description.isEmpty || time.isEmpty || (imageFile == null && existingImageUrl == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields'),
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String imageUrl = existingImageUrl ?? '';
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'title': title.trim(),
        'description': description.trim(),
        'image_url': imageUrl,
        'time': time,
        'location': location,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update the event.')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }





}

final eventController =
    ChangeNotifierProvider<EventController>((ref) => EventController());
