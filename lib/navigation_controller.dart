import 'package:flutter/material.dart';
import 'package:pdh_recommendation/main.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/search_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class NavigationController extends StatelessWidget {
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    DashboardPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Scaffold(
      body: _pages[appState.selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: appState.selectedIndex,
        onTap: (i) => appState.setSelectedIndex(i),
      ),
    );
  }
}