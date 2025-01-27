import 'package:burntech/controller/event_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/firebase_constant/firebase_constants.dart';
import '../../../../widget/custom_image.dart';

import '../events_detail_page.dart';

class EventCard extends ConsumerStatefulWidget {
  final String title;
  final String id;
  final String description;
  final String dateTime;
  final String imageUrl;
  final String eventType;
  final LatLng latLng;
  final bool? isDelete;

  const EventCard(
      {Key? key,
      required this.id,
      required this.title,
      required this.description,
      required this.dateTime,
      required this.imageUrl,
      required this.eventType,
      required this.latLng,
      this.isDelete})
      : super(key: key);

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<EventCard> {
  String? walkingTime = "0";
  String? bicyclingTime = "0";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) async {
      Map<String, dynamic>? dynamicData =
          await ref.read(eventController).calculateTravelTimes(widget.latLng);
      if (mounted) {
        setState(() {
          walkingTime = dynamicData?['walking'];
          bicyclingTime = dynamicData?['bicycling'];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EventDetailPage(
                  eventId: widget.id,
                  eventType: widget.eventType,
                )));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade100, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topRight,
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                    'assets/images/background_image_p.png',
                  ))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      widget.dateTime,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.directions_walk,
                                size: 20,
                              ),
                              Text(
                                '$walkingTime',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.directions_bike_outlined,
                                size: 20,
                              ),
                              Text(
                                ' $bicyclingTime',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: CustomImageView(
                  radius: BorderRadius.circular(10.0),
                  imagePath: widget.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              if (widget.isDelete != null)
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        try {
                          FirebaseConstants.firestore
                              .collection('events')
                              .doc(widget.id)
                              .delete();
                        } catch (e) {
                          print("something went wrong $e");
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
