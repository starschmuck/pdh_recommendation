import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdh_recommendation/widgets/individual_suggestion_card.dart';
import 'package:rxdart/utils.dart';
import 'package:async/async.dart';

import '../widgets/individual_review_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Placeholder values for now — later we’ll fetch from Firestore
    final String userName = "John Doe"; // TODO: pull from Firestore 'name' field
    final String? userEmail = user?.email;
    final String? profileImageUrl = null; // TODO: pull from Firestore or Storage

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                    // --- Profile Image ---
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),

                    const SizedBox(height: 12),

                    // --- Name ---
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // --- Email ---
                    if (userEmail != null)
                      Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // --- Favorite Dishes Header ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Favorite Dishes",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Placeholder for favorite dishes ---
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        final favorites = (data?['favorites'] as List<dynamic>?)
                            ?.map((e) => e.toString())
                            .toList() ?? [];

                        if (favorites.isEmpty) {
                          return const Text("You haven’t marked any favorites yet.");
                        }

                        return Column(
                          children: favorites.map((meal) {
                            return ListTile(
                              title: Text(meal),
                              trailing: const Icon(Icons.favorite, color: Colors.pink),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),

                    // --- Recent Activity Header ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Recent Activity",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- Recent Activity Feed ---
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
                              'timestamp': (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0),
                            });

                        final suggestions = snapshot.data![1].docs.map((doc) => {
                              'type': 'suggestion',
                              'doc': doc,
                              'timestamp': (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0),
                            });

                        final allActivities = [...reviews, ...suggestions];
                        allActivities.sort((a, b) =>
                            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

                        final recent = allActivities.take(5).toList();

                        if (recent.isEmpty) {
                          return const Text("No recent activity.");
                        }

                        return Column(
                          children: recent.map((activity) {
                            final doc = activity['doc'] as DocumentSnapshot<Map<String, dynamic>>;
                            if (activity['type'] == 'review') {
                              return IndividualReviewCard(doc: doc);
                            } else {
                              return IndividualSuggestionCard(doc: doc);
                            }
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // --- Placeholder for actions ---
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: implement logout
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out"),
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