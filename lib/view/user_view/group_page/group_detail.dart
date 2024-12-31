import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:burntech/widget/custom_out_lined_button.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/utils_constants/utils_constants.dart';
import 'volunteer_form.dart';
import 'volunteer_people_list.dart';

class GroupDetailPage extends StatefulWidget {
  final Map<String, dynamic> groupData;

  GroupDetailPage({required this.groupData});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            child: SizedBox(
              height: 300,
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
                    markerId: MarkerId(widget.groupData['title'] ?? 'No Title'),
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
                    Flexible(
                      child: GestureDetector(
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Row(
        children: [
          Flexible(
            child: CustomElevatedButton(
              onPressed: () {
                print("group id ====  ${widget.groupData['id']}");
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return VolunteerFormPage(
                    groupId: widget.groupData['id'],
                  );
                }));
              },
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              text: "Apply for volunteer",
            ),
          ),
          Flexible(
            child: CustomOutlinedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return VolunteersListPage(groupId: widget.groupData['id']);
                }));
              },
              text: "Volunteer list",
            ),
          )
        ],
      ),
    );
  }
}
