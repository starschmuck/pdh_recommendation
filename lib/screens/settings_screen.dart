import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _performFullLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out')),
      );
      // AuthWrapper should handle redirect to login automatically.
      Navigator.pop(context); // go back after logout
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar with automatic back arrow (or explicit BackButton)
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(), // returns to previous (Profile) screen
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () => _performFullLogout(context),
            ),
            const Divider(height: 32),
            const Text(
              'App',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
