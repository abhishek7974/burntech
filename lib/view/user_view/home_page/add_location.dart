import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:burntech/widget/custom_image.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/home_controller.dart';
import '../../../core/utils_constants/utils_constants.dart';


class AddLocationPage extends ConsumerStatefulWidget {
  LatLng? latLng;

  AddLocationPage({this.latLng});
  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends ConsumerState<AddLocationPage> {
  GoogleMapController? _mapController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      final homeData = ref.watch(homeProvider);
      homeData.loadMarkers(context);
      homeData.setParentContext(context);
    });
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.terrain
              : _currentMapType == MapType.terrain
                  ? MapType.hybrid
                  : MapType.normal;
    });
  }

  final LatLng _blackRockCity = LatLng(40.7864, -119.2065);

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeProvider);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: (controller) => _mapController = controller,
            onTap: (value) {

              showEditMarkerDialog(value, context);
            },
            initialCameraPosition: CameraPosition(
              target: widget.latLng ?? _blackRockCity,
              zoom: 16,
            ),
            markers: homeData.markerPoints,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(13, 25),
          ),
          Stack(
            children: [
              Positioned(
                top: 50,
                right: 0,
                child: GestureDetector(
                  onTap: _toggleMapType,
                  child: Container(
                    width: 130,
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black54,
                        border: Border()),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Map type",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildDialogOption({
  required String label,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(icon, color: color),
        ],
      ),
    ),
  );
}

void showMarkerTypeDialog(LatLng latLng, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select Marker Type"),
        content: Consumer(builder: (context, ref, child) {
          final homeData = ref.watch(homeProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDialogOption(
                label: "Camp",
                icon: Icons.cabin,
                color: Colors.blue,
                onTap: () {
                  // homeData.updateMarker(latLng, "Camp", context);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10),
              buildDialogOption(
                label: "Vehicle",
                icon: Icons.directions_bike_outlined,
                color: Colors.blue,
                onTap: () {
                  // homeData.updateMarker(latLng, "Vehicle", context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }),
      );
    },
  );
}

showRemoveMarkerDialog(
    MarkerId markerId, Map<String, dynamic> data, BuildContext parentContext) async {
  await showDialog(
    context: parentContext,
    builder: (context) {
      return AlertDialog(
        title: Text("${data['type']} details"),
        content: Consumer(builder: (context, ref, child) {
          final homeData = ref.read(homeProvider);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDialogOption(
                label: "Direction",
                icon: Icons.directions,
                color: Colors.blue,
                onTap: () {
                  UtilsConstant.openGoogleMaps(
                      LatLng(data['latitude'], data['longitude']));
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 10),
              buildDialogOption(
                label: "Remove marker",
                icon: Icons.cancel,
                color: Colors.red,
                onTap: () {
                  homeData.removeMarker(markerId);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }),
      );
    },
  );
}

void showEditMarkerDialog(LatLng latLng, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return EditMarkerDialog(latLng);
      });
}

class EditMarkerDialog extends ConsumerStatefulWidget {
  LatLng latLng;

  EditMarkerDialog(this.latLng);

  @override
  ConsumerState<EditMarkerDialog> createState() => _EditMarkerDialogState();
}

class _EditMarkerDialogState extends ConsumerState<EditMarkerDialog> {
  final TextEditingController titleController = TextEditingController(text: "");

  int selectedIndex = 0;

  List<String> imagesList = [
    'assets/images/home.png',
    'assets/images/location_pin.png',
    'assets/images/pin.png',
    'assets/images/bycycle.png',
  ];

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeProvider);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Marker",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Text Field
            CustomTextFormField(
              controller: titleController,
              hintText: "Marker ",
            ),
            SizedBox(height: 24),

            // Icon Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIconButton(
                  context,
                  icon: 'assets/images/home.png',
                  label: "Move",
                  color: Colors.blue,
                  isSelected: selectedIndex == 0,
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
                _buildIconButton(
                  context,
                  icon: 'assets/images/location_pin.png',
                  label: "Delete",
                  color: Colors.red,
                  isSelected: selectedIndex == 1,
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
                _buildIconButton(
                  context,
                  icon: 'assets/images/pin.png',
                  label: "Bike",
                  color: Colors.green,
                  isSelected: selectedIndex == 2,
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),
                _buildIconButton(
                  context,
                  icon: 'assets/images/bycycle.png',
                  label: "Save",
                  color: Colors.pink,
                  isSelected: selectedIndex == 3,
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                    child: CustomElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            homeData.updateMarker(
                                widget.latLng,
                                titleController.text.trim(),
                                imagesList[selectedIndex],
                                context);
                            Navigator.of(context).pop();
                          }
                        },
                        height: 40,
                        margin: EdgeInsets.all(10),
                        text: 'Save')),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    height: 40,
                    margin: EdgeInsets.all(10),
                    text: 'Cancel',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: isSelected
                    ? Border.all(
                        color: Colors.black54,
                      )
                    : null),
            child: CustomImageView(
              height: 30,
              width: 30,
              imagePath: icon,
            ),
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
