import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/utils_constants/utils_constants.dart';
import '../group_detail.dart';

class GroupCard extends StatefulWidget {
  final Map<String, dynamic> groupData;
  final String? groupId;

  const GroupCard({Key? key,this.groupId, required this.groupData}) : super(key: key);

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return GroupDetailPage(groupData: widget.groupData);
        }));
      },
      child: Card(
        margin: const EdgeInsets.all(16.0),
        elevation: 4.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10), topLeft: Radius.circular(10)),
              child: SizedBox(
                height: 150,
                child: GoogleMap(
                  mapType: MapType.satellite,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.groupData["location"]["latitude"],
                        widget.groupData["location"]["longitude"]),
                    zoom: 14,
                  ),
                  onTap: (LatLng location) {},
                  markers: {
                    Marker(
                      markerId:
                          MarkerId(widget.groupData['title'] ?? 'No Title'),
                      position: LatLng(widget.groupData["location"]["latitude"],
                          widget.groupData["location"]["longitude"]),
                    )
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    widget.groupData['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  Text(
                    widget.groupData['description'] ?? 'No Description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Event Details
                  Row(
                    children: [
                      const Icon(Icons.event, size: 20.0, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Text(
                        UtilsConstant.formatCreatedAt(
                            widget.groupData['createdAt']),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.local_offer,
                          size: 20.0, color: Colors.green),
                      const SizedBox(width: 8.0),
                      Text(
                        widget.groupData['offers']?.join(', ') ?? 'No Offers',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 20.0, color: Colors.red),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () {
                          UtilsConstant.openGoogleMaps(LatLng(
                              widget.groupData['location'].latitude,
                              widget.groupData['location'].longitude));
                        },
                        child: Text(
                          'Navigate',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                      Spacer(),
                      if(widget.groupId != null)
                      IconButton(
                          onPressed: () async {
                            try {
                              FirebaseConstants.firestore
                                  .collection('groups')
                                  .doc(widget.groupId)
                                  .delete();

                            } catch (e) {
                              print("something went wrong $e");
                            }
                          },
                          icon: Icon(Icons.delete,color: Colors.red,)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
