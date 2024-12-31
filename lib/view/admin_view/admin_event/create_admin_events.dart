import 'dart:io';

import 'package:burntech/core/utils_constants/utils_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/event_controller.dart';
import '../../../widget/custom_elevated_button.dart';
import '../../../widget/custom_text_form_field.dart';

class CreateAdminEvent extends ConsumerStatefulWidget {
  final String? eventType;

  CreateAdminEvent({
    this.eventType,
  });

  @override
  _CreateAdminEventState createState() => _CreateAdminEventState();
}

class _CreateAdminEventState extends ConsumerState<CreateAdminEvent> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timePickerController = TextEditingController();

  File? _imageFile;
  TimeOfDay? _selectedTime;
  LatLng _selectedLocation = LatLng(40.7864, -119.2065);

  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _timePickerController.text.isEmpty ||
        _imageFile == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all the fields',
          ),
        ),
      );
      return;
    }

    final eventCont = ref.read(eventController);

    final imageUrl = await eventCont.uploadImage(_imageFile!);
    await eventCont.saveEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: imageUrl,
      eventType: widget.eventType ?? 'events',
      time:
          '${_selectedTime!.hourOfPeriod}:${_selectedTime!.minute} ${_selectedTime!.period.name.toUpperCase()}',
      location: _selectedLocation,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event saved successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${(widget.eventType ?? "Event").toCapitalized} details',
        ),
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
                          ? Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey[700])
                          : Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomElevatedButton(
                    onPressed: _saveEvent,
                    text: 'Save Event',
                  ),
                ],
              ),
            ),
          ),
          if (ref.watch(eventController).isLoading)
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
