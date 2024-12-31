import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/group_controller.dart';


class CreateGroupPage extends ConsumerStatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController  priceController = TextEditingController();


   List<String> offerOptions = ['Free Tickets', 'Food', 'Shelter', 'Clothing', 'Other'];
  List<String> selectedOffers = [];


  LatLng _selectedLocation = LatLng(40.7864, -119.2065);

  Future<void> submitGroup() async {
    if (!_formKey.currentState!.validate()) return;

      final data = {
        'title': titleController.text,
        'description': descriptionController.text,
        'user_id' : FirebaseConstants.cUId,
        'price': priceController.text,
        'offers': selectedOffers,
        'location': {
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
        },
        'createdAt': DateTime.now().toString(),
      };

      ref.read(groupControllerNotifier).createGroup(context, data);

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create volunteer request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 200,
                    child: GoogleMap(
                      mapType: MapType.satellite,
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 14,
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
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Group name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CustomTextFormField(
                  controller: titleController,
                  hintText: 'Enter group name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CustomTextFormField(
                  controller: priceController,
                  hintText: 'Enter the price ',
                  textInputType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                CustomTextFormField(
                  controller: descriptionController,
                  hintText: 'Enter group description',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'What You Can Offer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    // Show multi-select dialog
                    final selected = await showDialog<List<String>>(
                      context: context,
                      builder: (context) {
                        return MultiSelectDialog(
                          items: offerOptions,
                          initialSelectedValues: selectedOffers,
                        );
                      },
                    );

                    if (selected != null) {
                      setState(() {
                        selectedOffers = selected;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedOffers.isEmpty
                          ? 'Select what you can offer'
                          : selectedOffers.join(', '),
                      style: TextStyle(color: selectedOffers.isEmpty ? Colors.grey : Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: CustomElevatedButton(
                    onPressed: () async{
                      print("object +++ ");
                     await submitGroup();
                    },
                    text: 'Submit',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> items;
  final List<String> initialSelectedValues;

  MultiSelectDialog({
    required this.items,
    this.initialSelectedValues = const [],
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> selectedValues;

  @override
  void initState() {
    super.initState();
    selectedValues = List.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Options'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.items.map((item) {
            return CheckboxListTile(
              value: selectedValues.contains(item),
              title: Text(item),
              onChanged: (isSelected) {
                setState(() {
                  isSelected == true
                      ? selectedValues.add(item)
                      : selectedValues.remove(item);
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedValues),
          child: Text('OK'),
        ),
      ],
    );
  }
}
