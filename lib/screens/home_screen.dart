import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';
// later we’ll import the new widgets
import '../widgets/weekly_review_card.dart';
// import '../widgets/weekly_suggestion_card.dart'; // ignore for now
import 'review_screen.dart';
import 'suggestion_screen.dart';
import '../widgets/weekly_suggestion_card.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFabExpanded = false;
  late final Stream<QuerySnapshot> _reviewsStream;
  // suggestions stream left in place but unused for now
  late final Stream<QuerySnapshot> _suggestionsStream;

  @override
  void initState() {
    super.initState();
    final weekAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );

    _reviewsStream = FirebaseFirestore.instance
        .collection('reviews')
        .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();

    _suggestionsStream = FirebaseFirestore.instance
        .collection('suggestions')
        .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reviews section
                    StreamBuilder<QuerySnapshot>(
                      stream: _reviewsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("No reviews this week."),
                          );
                        }
                        final docs = snapshot.data!.docs;
                        // NEW: pass docs into WeeklyReviewCard
                        return WeeklyReviewCard(reviewDocs: docs);
                      },
                    ),

                    const SizedBox(height: 16.0),

                    // Suggestions section
                    StreamBuilder<QuerySnapshot>(
                      stream: _suggestionsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No suggestions this week."));
                        }
                        final docs = snapshot.data!.docs;
                        return WeeklySuggestionCard(suggestionDocs: docs);
                      },
                    ),

                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFabCluster(context),
    );
  }

  Widget _buildFabCluster(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 200.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'review',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewPage()),
                  );
                  _toggleFab();
                },
                label: const Text('Review'),
                icon: const Icon(Icons.rate_review),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 140.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'guess',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: _toggleFab,
                label: const Text('Guess'),
                icon: const Icon(Icons.help_outline),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 80.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'suggest',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuggestionPage()),
                  );
                  _toggleFab();
                },
                label: const Text('Suggest'),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            heroTag: 'toggle',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: _toggleFab,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}