import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/event_controller.dart';
import '../../../widget/custom_image.dart';
import '../../user_view/events_page/widget/comments_model.dart';
import '../../user_view/events_page/widget/events_card.dart';
import 'widget/admin_event_card.dart';

class AdminEvetsDetails extends ConsumerStatefulWidget {
  String? eventId;

  AdminEvetsDetails({this.eventId, super.key});

  @override
  ConsumerState<AdminEvetsDetails> createState() => _AdminEvetsDetailsState();
}

class _AdminEvetsDetailsState extends ConsumerState<AdminEvetsDetails> {
  late Future<DocumentSnapshot> eventDataFuture;

  @override
  void initState() {
    super.initState();

    eventDataFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final eventDataCont = ref.watch(eventController);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Details',
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
                        onTap: () async {},
                        child: Text(
                          time,
                          style:
                          TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text("Comments "),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("events/${widget.eventId}/comments")
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No comments yet.'));
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return FutureBuilder(
                              future: FirebaseConstants.getCurrentUser(
                                  userId: comment['userId']),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return Center(child: Text(''));
                                }

                                final userData = userSnapshot.data!;
                                final userName =
                                    userData['name'] ?? 'Unknown User';
                                final userProfileImage = userData[
                                'profileImage'] ??
                                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKydNzoaNd7bkwENwlshdrHfsavKUloX5UMg&s';
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                    NetworkImage(userProfileImage),
                                    radius: 20,
                                  ),
                                  title: Text(
                                    userName,
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(comment['comment']),
                                  trailing: IconButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection("events/${widget.eventId}/comments")
                                              .doc(comment.id)
                                              .delete();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Comment deleted successfully!"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Failed to delete comment: $e"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.delete)),
                                );
                              });
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
