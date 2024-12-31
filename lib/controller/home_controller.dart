import 'dart:convert';

import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import '../view/admin_view/admin_home/add_location_admin.dart';
import '../view/user_view/home_page/add_location.dart' as home;


class HomeController extends ChangeNotifier {

  BuildContext? _parentContext;

  List<Map<String, dynamic>> allLocations = [];

  void setParentContext(BuildContext context) {

    _parentContext = context;

  }


  Set<Marker> markerPoints = {

  };

  void updateMarker(LatLng latLng, String markerType, String imagePath, BuildContext context) async {
    final markerData = {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'image_path': imagePath,
      'type': markerType,
    };

    final markerId = MarkerId(markerType);
     createMarker(markerId, latLng, markerData, context).then((value){
      markerPoints.add(value);
      notifyListeners();
    });

    notifyListeners();

    try {

      await FirebaseConstants.firestore
          .collection('users')
          .doc(FirebaseConstants.cUId)
          .collection('markerData')
          .add(markerData);
      loadAllLocations();
    } catch (e) {
      print('Error updating marker: $e');
    }
  }

  void updateMarkerAdmin(LatLng latLng, String markerType, String imagePath, BuildContext context) async {
    final markerData = {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
      'image_path': imagePath,
      'type': markerType,
    };

    final markerId = MarkerId(markerType);
    createMarker(markerId, latLng, markerData, context).then((value){
      markerPoints.add(value);
      notifyListeners();
    });

    notifyListeners();

    try {

      await FirebaseConstants.firestore
          .collection('markerData')
          .add(markerData);
      loadAllLocationsAdmin();
    } catch (e) {
      print('Error updating marker: $e');
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<Marker> createMarker(MarkerId markerId, LatLng position,
      Map<String, dynamic> data, BuildContext context) async{
    final Uint8List markerIcon = await getBytesFromAsset(data['image_path'], 100);

    return Marker(
      icon: BitmapDescriptor.fromBytes(markerIcon),
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: data['type']),
      onTap: () async{
       await home.showRemoveMarkerDialog(markerId, data,  _parentContext!);
      } ,
    );
  }

  Future<Marker> adminCreateMarker(MarkerId markerId, LatLng position,
      Map<String, dynamic> data, BuildContext context) async{
    final Uint8List markerIcon = await getBytesFromAsset(data['image_path'], 100);

    return Marker(
      icon: BitmapDescriptor.fromBytes(markerIcon),
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: data['type']),
      onTap: () async{
       await showRemoveMarkerDialog(markerId, data,  _parentContext!);
      } ,
    );
  }

  Future<void> removeMarker(MarkerId markerId) async {
    markerPoints = markerPoints.where((marker) => marker.markerId != markerId).toSet();
    notifyListeners();

    try {
      final markersCollection = await FirebaseConstants.firestore
          .collection('users')
          .doc(FirebaseConstants.cUId)
          .collection('markerData')
          .get();

      for (var doc in markersCollection.docs) {
        if (doc.data()['type'] == markerId.value) {
          await doc.reference.delete();
          break;
        }
      }
      loadAllLocations();
    } catch (e) {
      print('Error removing marker: $e');
    }
  }


  Future<void> removeMarkerAdmin(MarkerId markerId) async {
    markerPoints = markerPoints.where((marker) => marker.markerId != markerId).toSet();
    notifyListeners();

    try {
      final markersCollection = await FirebaseConstants.firestore
          .collection('markerData')
          .get();

      for (var doc in markersCollection.docs) {
        if (doc.data()['type'] == markerId.value) {
          await doc.reference.delete();
          break;
        }
      }
      loadAllLocationsAdmin();
    } catch (e) {
      print('Error removing marker: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      // Request permission
      status = await Permission.location.request();
      if (status.isGranted) {
        print('Location permission granted!');
      } else if (status.isDenied) {
        print('Location permission denied.');
      } else if (status.isPermanentlyDenied) {
        print('Location permission permanently denied. Please enable it in settings.');
        openAppSettings(); // Opens the app settings for the user to manually enable permissions.
      }
    } else if (status.isGranted) {
      print('Location permission already granted.');
    }
  }

  Future<void> loadMarkers(BuildContext context) async {
    try {
     await requestLocationPermission();
      markerPoints = {};
      notifyListeners();
      final markersCollection = await FirebaseConstants.firestore
          .collection('users')
          .doc(FirebaseConstants.cUId)
          .collection('markerData')
          .get();
      final markersCollectionAdmin = await FirebaseConstants.firestore
          .collection('markerData')
          .get();

      final Set<Marker> loadedMarkers = {};

      for (var doc in markersCollection.docs) {
        final data = doc.data();
        final markerId = MarkerId(data['type']);

        final Uint8List markerIcon = await getBytesFromAsset(data['image_path'], 100);

        final marker = Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: markerId,
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(title: data['type']),
          onTap: () async{
            await home.showRemoveMarkerDialog(markerId, data,  _parentContext!);
          } , // Pass context if available
        );
        loadedMarkers.add(marker);
      }

      for (var doc in markersCollectionAdmin.docs) {
        final data = doc.data();
        final markerId = MarkerId(data['type']);

        final Uint8List markerIcon = await getBytesFromAsset(data['image_path'], 100);

        final marker = Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: markerId,
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(title: data['type']),
          onTap: () async{

          } , // Pass context if available
        );
        loadedMarkers.add(marker);
      }

      markerPoints = loadedMarkers;
      notifyListeners();

    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  Future<void> loadMarkersAdmin(BuildContext context) async {
    markerPoints = {};
    notifyListeners();
    try {
      final markersCollection = await FirebaseConstants.firestore
          .collection('markerData')
          .get();

      final Set<Marker> loadedMarkers = {};

      for (var doc in markersCollection.docs) {
        final data = doc.data();
        final markerId = MarkerId(data['type']);

        final Uint8List markerIcon = await getBytesFromAsset(data['image_path'], 100);

        final marker = Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: markerId,
          position: LatLng(data['latitude'], data['longitude']),
          infoWindow: InfoWindow(title: data['type']),
          onTap: () async{
            await showRemoveMarkerDialog(markerId, data,  _parentContext!);
          } , // Pass context if available
        );
        loadedMarkers.add(marker);
      }

      markerPoints = loadedMarkers;
      notifyListeners();

    } catch (e) {
      print('Error loading markers: $e');
    }
  }



  Future<List<dynamic>> fetchHospitals() async {

    final apiKey = 'AIzaSyBQ8YNTVrh7FXmAkttnDNhdjTqm4Inynko';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7864,-119.2066&radius=5000&type=hospital&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("data ==== $data");
      markerPoints = data.map<Marker>((hospital) {
        final location = hospital['geometry']['location'];
        return Marker(
          markerId: MarkerId(hospital['place_id']),
          position: LatLng(location['lat'], location['lng']),
          infoWindow: InfoWindow(
            title: hospital['name'],
            snippet: hospital['vicinity'],
          ),
        );
      }).toSet();
      notifyListeners();
      return data['results'];
    } else {
      throw Exception('Failed to load hospitals');
    }
  }


  Future<void> loadAllLocations() async {
    try {

      final querySnapshot = await FirebaseFirestore.instance
          .collection(
          'users/${FirebaseConstants.auth.currentUser?.uid}/markerData') // Fetch all markers across users
          .get();

      final List<Map<String, dynamic>> locations =
      querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'type': data['type'] ?? 'Unknown',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'userId': doc.reference.parent.parent?.id,
          'image_path': data['image_path']
        };
      }).toList();



        allLocations = locations;
        notifyListeners();

      // loadAllLocationsAdmin();

    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  Future<void> loadAllLocationsAdmin() async {
    try {

      final querySnapshot = await FirebaseFirestore.instance
          .collection(
          'markerData') // Fetch all markers across users
          .get();

      final List<Map<String, dynamic>> locations =
      querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'type': data['type'] ?? 'Unknown',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'userId': doc.reference.parent.parent?.id,
          'image_path': data['image_path']
        };
      }).toList();

      allLocations = locations;
      notifyListeners();

    } catch (e) {
      print('Error loading locations: $e');
    }
  }


}

final homeProvider = ChangeNotifierProvider<HomeController>((ref) => HomeController());
