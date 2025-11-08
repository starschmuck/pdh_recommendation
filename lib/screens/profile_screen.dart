import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdh_recommendation/widgets/individual_suggestion_card.dart';
import 'package:rxdart/utils.dart';
import 'package:async/async.dart';

import '../widgets/individual_review_card.dart';
import 'settings_screen.dart'; // NEW

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // --- Settings button (opens without nav bar) --- NEW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Settings'),
                        ),
                      ],
                    ),
                    // --- Profile Info from Firestore ---
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                        final userName = data?['name'] ?? 'Unnamed User';
                        final userEmail = user?.email ?? '';

                        return Column(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Favorite Dishes",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final favorites = (data?['favorites'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ??
                            [];

                        if (favorites.isEmpty) {
                          return const Text(
                              "You haven’t marked any favorites yet.");
                        }

                        return Column(
                          children: favorites.map((meal) {
                            return ListTile(
                              title: Text(meal),
                              trailing:
                                  const Icon(Icons.favorite, color: Colors.pink),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recent Activity",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    StreamBuilder<List<QuerySnapshot>>(
                      stream: StreamZip([
                        FirebaseFirestore.instance
                            .collection('reviews')
                            .where('userId', isEqualTo: user?.uid)
                            .snapshots(),
                        FirebaseFirestore.instance
                            .collection('suggestions')
                            .where('userId', isEqualTo: user?.uid)
                            .snapshots(),
                      ]),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final reviews = snapshot.data![0].docs.map((doc) => {
                              'type': 'review',
                              'doc': doc,
                              'timestamp':
                                  (doc['timestamp'] as Timestamp?)?.toDate() ??
                                      DateTime(0),
                            });

                        final suggestions = snapshot.data![1].docs.map((doc) => {
                              'type': 'suggestion',
                              'doc': doc,
                              'timestamp':
                                  (doc['timestamp'] as Timestamp?)?.toDate() ??
                                      DateTime(0),
                            });

                        final allActivities = [...reviews, ...suggestions];
                        allActivities.sort((a, b) =>
                            (b['timestamp'] as DateTime).compareTo(
                                a['timestamp'] as DateTime));

                        final recent = allActivities.take(5).toList();

                        if (recent.isEmpty) {
                          return const Text("No recent activity.");
                        }

                        return Column(
                          children: recent.map((activity) {
                            final doc = activity['doc']
                                as DocumentSnapshot<Map<String, dynamic>>;
                            if (activity['type'] == 'review') {
                              return IndividualReviewCard(doc: doc);
                            } else {
                              return IndividualSuggestionCard(doc: doc);
                            }
                          }).toList(),
                        );
                      },
                    ),     
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}