import 'package:burntech/controller/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/theme_helper.dart';
import '../events_page/widget/events_card.dart';

class FavouritesPage extends ConsumerStatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends ConsumerState<FavouritesPage> {
  // List<String> likedEventIds = [];
  // bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      ref.read(commentController).fetchLikedPosts();
    });
  }

  // Future<void> _fetchLikedPosts() async {
  //   final userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseConstants.auth.currentUser?.uid);
  
  //   final userSnapshot = await userDoc.get();

  //   if (userSnapshot.exists) {
  //     final likedEvents = List<String>.from(userSnapshot.data()?['liked_events'] ?? []);
  //     setState(() {
  //       likedEventIds = likedEvents;
  //       isLoading = false;
  //     });
  //   } else {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final commentCont = ref.watch(commentController);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Events page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: commentCont.isLoading
          ? Center(child: CircularProgressIndicator())
          : commentCont.likedEventIds.isEmpty
              ? Center(
                  child: Text(
                    'No liked posts found.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: commentCont.likedEventIds.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('events')
                          .doc(commentCont.likedEventIds[index])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return SizedBox.shrink();
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return SizedBox
                              .shrink(); // Skip if the event is not found
                        }

                        final event = snapshot.data!;

                        return EventCard(
                          id: event.id,
                          title: event['title'],
                          description: event['description'],
                          dateTime: event['time'],
                          imageUrl: event['image_url'],
                          eventType: event['events_type'] ?? "Event",
                          latLng: LatLng(event['location']['latitude'],
                              event['location']['longitude']),
                        );
                        ;
                      },
                    );
                  },
                ),
    );
  }
}
