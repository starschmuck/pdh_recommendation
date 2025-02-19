import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Text('Welcome to the Home Page!'),
        ),
      );
  }
}