

import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/core/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../controller/user_controller.dart';
import '../events_page/events_detail_page.dart';
import '../events_page/widget/events_card.dart';
import '../group_page/volunteer_group_list.dart';
import '../group_page/widgets/group_card.dart';
import '../onboarding_screen/onboarding_screen.dart';

class ProfilePage extends ConsumerStatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((call){
      ref.read(userController).fetchUserProfile();
    });
    _tabController = TabController(length: 3, vsync: this);
  }



  @override
  Widget build(BuildContext context) {
  final userData =  ref.watch(userController);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Profile Page',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await FirebaseConstants.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => OnboardingScreen(),
                  ),
                  (route) => false,
                );
              } catch (e) {
                print('Error signing out: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error signing out. Please try again.')),
                );
              }
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: userData.isLoading
          ? Center(child: CircularProgressIndicator())
          : userData.userSnapshot == null
              ? Center(child: Text('No user information found'))
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      // labelColor: Colors.white,
                      unselectedLabelColor: Colors.black54,
                      // indicatorColor: Colors.white,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'Events', icon: Icon(Icons.event)),
                        Tab(text: 'Groups', icon: Icon(Icons.group)),
                        Tab(text: 'Alerts', icon: Icon(Icons.notifications)),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAllEventsTab(),
                          _buildVolunteerGroupsTab(),
                          _buildAlertsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAllEventsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('user_id', isEqualTo: FirebaseConstants.auth.currentUser?.uid)
          .snapshots(), // Real-time updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No volunteer groups found.'));
        }

        final groups = snapshot.data!.docs;
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final data = groups[index];
            final event = data.data() as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: EventCard(
                id: data.id,
                title: event['title'],
                description: event['description'],
                dateTime: event['time'],
                imageUrl: event['image_url'],
                eventType: event['events_type'] ?? "Event",
                latLng: LatLng(
                  event['location']['latitude'],
                  event['location']['longitude'],
                ),
                isDelete: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVolunteerGroupsTab() {
    print("user id === ${FirebaseConstants.cUId}");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('user_id', isEqualTo:FirebaseConstants.auth.currentUser?.uid)
          .snapshots(), // Real-time updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No volunteer groups found.'));
        }

        final groups = snapshot.data!.docs;
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final data = groups[index];
            final group = data.data() as Map<String, dynamic>;
            return GroupCard(
              groupData: group,
              groupId: data.id,
            );
          },
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('alerts')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No alerts found.'));
        }

        final alerts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: ListTile(
                  title: Text(
                    alert['title'] ?? 'No Title',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    alert['message'] ?? 'No Message',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<String>> _getLikedEvents() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      return List<String>.from(userSnapshot.data()?['liked_events'] ?? []);
    }
    return [];
  }
}
