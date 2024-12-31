import 'package:burntech/core/theme/theme_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../events_page/search_and_filter_page.dart';
import '../favourites/favourites_page.dart';
import '../group_page/volunteer_group_list.dart';
import '../group_page/volunteer_people_list.dart';
import '../home_page/home_page.dart';
import '../profile_page/profile_screen.dart';
import '../tickets_page/tickets_page.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SearchAndFilter(),
    VolunteerGroupList(),
    FavouritesPage(),
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
        backgroundColor: Colors.black,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
                Icons.home
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.map
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
                Icons.volunteer_activism
            ),
            label: 'volunteer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Favourites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex : _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
