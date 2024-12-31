import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

class EventModel {

  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child('event_images/$fileName');
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
    try{

      await FirebaseFirestore.instance.collection('events').add({
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
    } catch(e){

    }
  }
}
