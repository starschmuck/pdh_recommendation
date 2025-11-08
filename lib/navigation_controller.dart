import 'package:flutter/material.dart';
import 'package:pdh_recommendation/main.dart';
import 'package:provider/provider.dart';
import 'screens/main_review_screen.dart';       // NEW
import 'screens/main_suggestion_screen.dart';  // NEW
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/search_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class NavigationController extends StatelessWidget {
  NavigationController({super.key});

  final List<Widget> _pages = const [
    MainReviewScreen(),       // index 0
    MainSuggestionScreen(),   // index 1
    SearchPage(),             // index 2
    DashboardPage(),          // index 3
    ProfilePage(),            // index 4
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final safeIndex = appState.selectedIndex.clamp(0, _pages.length - 1);

    return Scaffold(
      body: _pages[safeIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: safeIndex,
        onTap: (i) => appState.setSelectedIndex(i),
      ),
    );
  }
}