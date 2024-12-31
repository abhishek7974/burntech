import 'package:burntech/controller/event_controller.dart';
import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/core/utils_constants/utils_constants.dart';
import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:burntech/widget/custom_image.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../../../core/notification_service/notification_service.dart';
import 'widget/comments_model.dart';
import 'package:timezone/timezone.dart' as tz;

class EventDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  final String eventType;

  EventDetailPage({required this.eventId, required this.eventType});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  late Future<DocumentSnapshot> eventDataFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      final eventData = ref.watch(eventController);
      eventData.fetchLikedStatus(widget.eventId);
    });
    eventDataFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get(); // Load event data once
  }



  @override
  Widget build(BuildContext context) {
    final eventDataCont = ref.watch(eventController);
    return Scaffold(
      appBar:

      AppBar(

        title: Text(
          '${widget.eventType.toCapitalized ?? "Event"} Details',
        ),
        backgroundColor: Colors.grey.shade200,
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: eventDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Event not found'),
            );
          }

          final eventData = snapshot.data!;
          final title = eventData['title'] ?? 'No Title';
          final description = eventData['description'] ?? 'No Description';
          final time = eventData['time'] ?? 'No Time';
          final imageUrl = eventData['image_url'] ?? '';
          final location = eventData['location'];

          LatLng? eventLocation;
          if (location != null) {
            eventLocation = LatLng(location['latitude'], location['longitude']);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImageView(
                    imagePath: imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(15.0),
                  ),
                  SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: ()async{

                        },
                        child: Text(
                          time,
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                eventDataCont.likePost(widget.eventId);
                              },
                              icon: Icon(
                                eventDataCont.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 30,
                                color: eventDataCont.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: eventLocation != null
                                  ? () => UtilsConstant.openGoogleMaps(
                                      eventLocation!)
                                  : null,
                              icon: Icon(
                                Icons.directions,
                                size: 30,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                print("notification clicked");
                                DateTime scheduledDate = DateTime.now().add( const Duration(seconds: 5));
                                NotificationService.scheduleNotification(
                                  0,
                                  "Scheduled Notification",
                                  "This notification is scheduled to appear after 5 seconds",
                                  scheduledDate,
                                );
                              },
                              icon: Icon(
                                 Icons.add_alert_rounded,
                                size: 30,
                                color:  Colors.grey,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: CommentModel(eventId: widget.eventId,),
    );
  }
}





