import 'package:burntech/core/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class VolunteerDetailPage extends StatelessWidget {
  final Map<String, dynamic> volunteer;

  VolunteerDetailPage({required this.volunteer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text( 'Volunteer Details',style: TextStyle(color :Colors.white),),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: volunteer['profile_pic'] != null
                      ? NetworkImage(volunteer['profile_pic'])
                      : null,
                  child: volunteer['profile_pic'] == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey[700])
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  volunteer['name'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.grey[400]),
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: volunteer['email'] ?? 'No Email',
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: volunteer['phone'] ?? 'No Phone',
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.description,
                label: 'Reason',
                value: volunteer['reason'] ?? 'No Reason Provided',
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Address',
                value: volunteer['address'] ?? 'No Address',
              ),
              const SizedBox(height: 20),
              Text(
                'Application Date:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                volunteer['created_at']?.toDate().toString() ?? 'No Date',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
