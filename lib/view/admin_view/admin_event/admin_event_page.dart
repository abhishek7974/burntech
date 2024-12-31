import 'package:burntech/view/user_view/events_page/create_evets_page.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/event_controller.dart';
import '../../../core/firebase_constant/firebase_constants.dart';
import '../../../core/utils_constants/utils_constants.dart';
import '../../user_view/events_page/all_events_page.dart';
import '../admin_home/admin_search_screen.dart';
import 'create_admin_events.dart';
import 'widget/admin_event_card.dart';

class AdminEventPage extends ConsumerStatefulWidget {
  const AdminEventPage({super.key});

  @override
  ConsumerState<AdminEventPage> createState() => _AdminEventPageState();
}

class _AdminEventPageState extends ConsumerState<AdminEventPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventController).fetchEvents(
            eventType: "events",
            searchQuery: "",
            isSearching: false,
          );
    });
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eventListController = ref.watch(eventController);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Events page"),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CreateAdminEvent();
              }));
            },
            label: Text("Add event"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSlidingSegmentedControl<int>(
                  initialValue: selectedIndex,
                  children: {
                    0: Text('Events'),
                    1: Text('Campaign'),
                    2: Text('Arts'),
                  },
                  decoration: BoxDecoration(
                    color: CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.3),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 2.0),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInToLinear,
                  onValueChanged: (value) {
                    setState(() {
                      selectedIndex = value;
                    });

                    ref.read(eventController).fetchEvents(
                          eventType: selectedIndex == 0
                              ? 'events'
                              : selectedIndex == 1
                                  ? 'campaign'
                                  : 'art',
                          isSearching: false,
                          searchQuery: "",
                        );
                  },
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return SearchScreenAdmin();
                      }));
                    },
                    icon: Icon(CupertinoIcons.search))
              ],
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: eventListController.events.length,
              itemBuilder: (context, index) {
                final event = eventListController.events[index];
                return AdminEventCard(
                  id: event['id'],
                  title: event['title'],
                  description: event['description'],
                  dateTime: event['time'],
                  imageUrl: event['image_url'],
                  eventType: "Event",
                  latLng: LatLng(
                    event['location']['latitude'],
                    event['location']['longitude'],
                  ),
                  onTapDelete: () {
                    try {
                      FirebaseConstants.firestore
                          .collection("events")
                          .doc(event['id'])
                          .delete();
                      UtilsConstant.showSnackbarSuccess(
                          "Deleted successfully", );
                      ref.read(eventController).fetchEvents(
                            eventType: selectedIndex == 0
                                ? 'events'
                                : selectedIndex == 1
                                    ? 'campaign'
                                    : 'art',
                            isSearching: false,
                            searchQuery: "",
                          );
                    } catch (e) {
                      UtilsConstant.showSnackbarError(
                          "Something went wronf $e");
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
