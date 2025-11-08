import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdh_recommendation/widgets/star_rating.dart';

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PROFILE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.person),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Welcome, ${user?.email ?? 'user'}!',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recent Reviews
                    ExpansionTile(
                      title: const Text(
                        'My Recent Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('reviews')
                                  .where('userId', isEqualTo: user?.uid)
                                  .orderBy('timestamp', descending: true)
                                  .limit(5)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No recent reviews.'),
                              );
                            }
                            return Column(
                              children:
                                  docs.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final String mealName =
                                        data['meal'] ?? doc.id;
                                    final double rating =
                                        (data['rating'] != null)
                                            ? (data['rating'] as num).toDouble()
                                            : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            mealName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          StarRating(rating: rating),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Recent Suggestions
                    ExpansionTile(
                      title: const Text(
                        'My Recent Suggestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('suggestions')
                                  .where('userId', isEqualTo: user?.uid)
                                  .orderBy('timestamp', descending: true)
                                  .limit(5)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }
                            final docs = snapshot.data?.docs ?? [];
                            if (docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No recent suggestions.'),
                              );
                            }
                            return Column(
                              children:
                                  docs.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final String suggestionText =
                                        data['title'] ?? doc.id;
                                    final double rating =
                                        (data['rating'] != null)
                                            ? (data['rating'] as num).toDouble()
                                            : 0.0;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            suggestionText,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          StarRating(rating: rating),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),
                      ],
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
