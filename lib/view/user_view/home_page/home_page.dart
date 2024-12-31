import 'package:burntech/controller/home_controller.dart';

import 'package:burntech/widget/custom_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../events_page/guide_burning_man.dart';
import '../events_page/widget/events_card.dart';
import '../group_page/volunteer_group_list.dart';
import '../serach_screen/search_screen.dart';
import '../tickets_page/tickets_page.dart';
import 'add_location.dart';
import 'medical_locations.dart';
import 'widget/custom_horizontal_card.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((value) {
      ref.read(homeProvider).loadAllLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allLocation = ref.watch(homeProvider).allLocations;
    return Scaffold(
      appBar: AppBar(
        title: Text('Burn Tech'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SearchScreen();
              }));
            },
            icon: Icon(CupertinoIcons.search),
          ) ,
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //       return AdminBottomBar();
          //     }));
          //   },
          //   icon: Icon(CupertinoIcons.rectangle_3_offgrid),
          // )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  CustomImageView(
                    radius: BorderRadius.circular(20),
                    imagePath: 'assets/images/burning_man_event.webp',
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomCard(
                            icon: Icons.travel_explore,
                            text: "Guide",
                            onClick: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return GuideBurningMan();
                              }));
                            },
                          ),
                          SizedBox(width: 8),
                          CustomCard(
                            icon: Icons.airplane_ticket,
                            text: "Tickets",
                            onClick: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return TicketPage();
                              }));
                            },
                          ),
                          SizedBox(width: 8),
                          CustomCard(
                            icon: Icons.handshake,
                            text: "volunteer",
                            onClick: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return VolunteerGroupList();
                              }));
                            },
                          ),
                          SizedBox(width: 8),
                          CustomCard(
                            icon: Icons.medical_services,
                            text: "Medical",
                            onClick: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return MedicalLocation();
                              }));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Ongoing events ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('events_type', isEqualTo: 'events')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No events available.'),
                      );
                    }
                    final events = snapshot.data!.docs;

                    if (index >= events.length) {
                      return SizedBox
                          .shrink(); // In case the index exceeds the number of events
                    }
                    final event = events[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: EventCard(
                        id: event.id,
                        title: event['title'],
                        description: event['description'],
                        dateTime: event['time'],
                        imageUrl: event['image_url'],
                        eventType: "Event",
                        latLng: LatLng(event['location']['latitude'],
                            event['location']['longitude']),
                      ),
                    );
                  },
                );
              },
              childCount: 5,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add location",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AddLocationPage();
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25)),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: allLocation.length,
                    itemBuilder: (context, index) {
                      final location = allLocation[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        child: ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AddLocationPage(
                                  latLng: LatLng(location['latitude'],
                                      location['longitude']),
                                );
                              })).then((val) {
                                // loadAllLocations();
                              });
                            },
                            leading: Icon(
                              Icons.location_pin,
                              color: Colors.blue,
                            ),
                            title: Text(
                              location['type'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Lat: ${location['latitude']}, Lng: ${location['longitude']}'),
                            trailing: CustomImageView(
                              imagePath: location['image_path'],
                            )

                            // IconButton(
                            //   icon: Icon(Icons.map, color: Colors.green),
                            //   onPressed: () {
                            //     // Handle map navigation
                            //     final latLng = LatLng(
                            //         location['latitude'], location['longitude']);
                            //     // Open Google Maps or focus on this location
                            //   },
                            // ),
                            ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
