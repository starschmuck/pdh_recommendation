import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdh_recommendation/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdh_recommendation/screens/login_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ExpansionTile(
                    title: Text(
                      'Application Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      ExpansionTile(title: Text('Version History')),
                      ExpansionTile(title: Text('Permissions')),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Manage Reviews',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      ExpansionTile(title: Text('Flagged Reviews')),
                      ExpansionTile(title: Text('Resolved Issues')),
                      ExpansionTile(title: Text('All Reviews')),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Report A Problem',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      ExpansionTile(title: Text('Report A Bug')),
                      ExpansionTile(title: Text('Request A Feature')),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        // Sign out from Firebase Authentication.
                        await FirebaseAuth.instance.signOut();
                        // Remove the stored user ID from SharedPreferences.
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('userId');
                        // Navigate to the LoginPage, replacing the current route.
                        navigatorKey.currentState?.pushReplacement(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      },
                      child: Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
