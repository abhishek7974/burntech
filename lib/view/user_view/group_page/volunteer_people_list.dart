import 'package:burntech/controller/comment_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controller/group_controller.dart';
import 'widgets/volunteer_person_detail.dart';

class VolunteersListPage extends ConsumerWidget {
  final String groupId;

  VolunteersListPage({required this.groupId});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteers List'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.watch(groupControllerNotifier).fetchVolunteers(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching volunteers'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No volunteers found.'));
          }

          List<Map<String, dynamic>> volunteers = snapshot.data ?? [];

          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              var volunteer = volunteers[index];
              return Card(
                elevation: 5,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: volunteer['profile_pic'] != null
                        ? NetworkImage(volunteer['profile_pic'])
                        : null,
                    child: volunteer['profile_pic'] == null
                        ? Icon(Icons.person, size: 30)
                        : null,
                  ),
                  title: Text(
                    volunteer['name'] ?? 'No Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(volunteer['email'] ?? 'No Email'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VolunteerDetailPage(volunteer: volunteer),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
