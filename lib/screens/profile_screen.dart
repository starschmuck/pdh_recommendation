import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page')),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Text('Welcome to the Profile Page!'),
        ),
      );
  }
}