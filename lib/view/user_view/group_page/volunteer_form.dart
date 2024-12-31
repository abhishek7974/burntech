import 'package:burntech/controller/group_controller.dart';
import 'package:burntech/widget/custom_elevated_button.dart';
import 'package:burntech/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image_picker/image_picker.dart';

import 'dart:io';

class VolunteerFormPage extends ConsumerStatefulWidget {
  String groupId;

  VolunteerFormPage({required this.groupId});

  @override
  _VolunteerFormPageState createState() => _VolunteerFormPageState();
}

class _VolunteerFormPageState extends ConsumerState<VolunteerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  final _addressController = TextEditingController();
  File? _profileImage;

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Function to upload profile picture and get the URL



  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {

       final data = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'address' : _addressController.text,
          'reason' : _reasonController.text,
          'created_at': DateTime.now(),
        };

       ref.watch(groupControllerNotifier).
       submitForm(data,_profileImage,context,widget.groupId);

    }
  }

  @override
  Widget build(BuildContext context) {
   final isLoading = ref.watch(groupControllerNotifier).isloading;
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Application'),
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextFormField(
                controller: _nameController,
                hintText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              CustomTextFormField(
                controller: _emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextFormField(
                controller: _phoneController,
                hintText: 'Phone',
                textInputType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextFormField(
                controller: _reasonController,
                maxLines: 2,
                hintText: 'Why do you want to join us ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your why';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextFormField(
                controller: _addressController,
                maxLines: 1,
                hintText: 'Address ',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Profile Picture Upload
              Row(
                children: [
                  _profileImage != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(_profileImage!),
                          radius: 40,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person, size: 40),
                          radius: 40,
                        ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Upload Profile Picture'),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),

              Center(
                child: CustomElevatedButton(
                  onPressed: _submitForm,
                  text: 'Submit Application',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
