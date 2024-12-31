import 'package:flutter/material.dart';

import '../../../core/theme/theme_helper.dart';
import '../../user_view/events_page/search_and_filter_page.dart';
import '../../user_view/home_page/home_page.dart';
import '../../user_view/profile_page/profile_screen.dart';
import '../admin_event/admin_event_page.dart';
import '../admin_home/admin_home_page.dart';

class AdminBottomBar extends StatefulWidget {
  AdminBottomBar({super.key});

  @override
  State<AdminBottomBar> createState() => _AdminBottomBarState();
}

class _AdminBottomBarState extends State<AdminBottomBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdminHomePage(),
    AdminEventPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        elevation: 5,

        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: true,
        // Ensure selected labels are visible
        showUnselectedLabels: true,
        // Ensure unselected labels are visible
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Explore',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Profile',
          // ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
