import 'dart:io';

import 'package:burntech/core/utils_constants/utils_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../controller/event_controller.dart';
import '../../../widget/custom_elevated_button.dart';
import '../../../widget/custom_text_form_field.dart';

class EditAdminEvent extends ConsumerStatefulWidget {
  final String eventId;

  EditAdminEvent({
    required this.eventId,
  });

  @override
  _EditAdminEventState createState() => _EditAdminEventState();
}

class _EditAdminEventState extends ConsumerState<EditAdminEvent> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timePickerController = TextEditingController();

  File? _imageFile;
  String? _existingImageUrl;
  TimeOfDay? _selectedTime;
  LatLng _selectedLocation = LatLng(40.7864, -119.2065);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      // ref.read(eventController).fetchEventDetails(widget.eventId);
    });
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    if (eventDoc.exists) {
      final eventData = eventDoc.data()!;
      _titleController.text = eventData['title'] ?? '';
      _descriptionController.text = eventData['description'] ?? '';
      _timePickerController.text = eventData['time'] ?? '';
      _existingImageUrl = eventData['image_url'];
      if (eventData['location'] != null) {
        final location = eventData['location'];
        _selectedLocation = LatLng(location['latitude'], location['longitude']);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        backgroundColor: Colors.grey.shade200,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 200,
                      child: GoogleMap(
                        mapType: MapType.satellite,
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation,
                          zoom: 12,
                        ),
                        onTap: (LatLng location) {
                          setState(() {
                            _selectedLocation = location;
                          });
                        },
                        markers: {
                          Marker(
                            markerId: MarkerId('selectedLocation'),
                            position: _selectedLocation,
                          ),
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextFormField(
                    controller: _titleController,
                    hintText: 'Title',
                    maxLines: 1,
                  ),
                  SizedBox(height: 16),
                  CustomTextFormField(
                    controller: _descriptionController,
                    hintText: 'Description',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  CustomTextFormField(
                    readOnly: true,
                    controller: _timePickerController,
                    hintText: 'Time',
                    maxLines: 1,
                    onClick: () => _selectTime(context),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey[300],
                      child: _imageFile == null
                          ? (_existingImageUrl != null
                              ? Image.network(_existingImageUrl!,
                                  fit: BoxFit.cover)
                              : Icon(Icons.add_photo_alternate,
                                  size: 50, color: Colors.grey[700]))
                          : Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16),
                  ref.watch(eventController).isLoadingUpdate
                      ? CircularProgressIndicator()
                      : CustomElevatedButton(
                          onPressed: () async {
                            await ref.read(eventController).updateEvent(
                                  eventId: widget.eventId,
                                  title: _titleController.text,
                                  description: _descriptionController.text,
                                  time: _timePickerController.text,
                                  location: {
                                    'latitude': _selectedLocation.latitude,
                                    'longitude': _selectedLocation.longitude,
                                  },
                                  imageFile: _imageFile,
                                  existingImageUrl: _existingImageUrl,
                                  context: context,
                                );
                          },
                          text: 'Update Event',
                        ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _timePickerController.text = _selectedTime!.format(context);
      });
    }
  }
}
