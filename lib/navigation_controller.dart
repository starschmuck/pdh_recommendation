import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class NavigationController extends StatefulWidget {
  @override
  State<NavigationController> createState() => _NavigationControllerState();

}

class _NavigationControllerState extends State<NavigationController> {

  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ProfilePage(),
    SettingsPage(),
  ];

  void _onNavBarTapped(int index) {

    if (index == 3) {
      // Handle logout by navigating to login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTapped,
      ),
    );
  }

}