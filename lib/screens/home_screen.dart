import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/review_popup.dart';
import 'package:pdh_recommendation/widgets/suggestion_popup.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'review_screen.dart';
import '../widgets/review_card.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/action_button.dart';
import 'suggestion_screen.dart';
import 'package:pdh_recommendation/widgets/star_rating.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFabExpanded = false;
  late final Stream<QuerySnapshot> _reviewsStream;
  late final Stream<QuerySnapshot> _suggestionsStream;

  @override
  void initState() {
    super.initState();
    final weekAgo = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: 7)),
    );
    _reviewsStream =
        FirebaseFirestore.instance
            .collection('reviews')
            .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots();

    _suggestionsStream =
        FirebaseFirestore.instance
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
    final Color fitCrimson = const Color.fromARGB(255, 119, 0, 0);
    final appState = Provider.of<MyAppState>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body:
          appState.isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _reviewsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error.toString()}',
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No reviews this week."),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          return ReviewCard(reviewDocs: docs);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      StreamBuilder<QuerySnapshot>(
                        stream: _suggestionsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error.toString()}',
                              ),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No suggestions this week."),
                            );
                          }
                          final docs = snapshot.data!.docs;
                          return SuggestionCard(suggestionDocs: docs);
                        },
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            right: 16.0,
            bottom: _isFabExpanded ? 200.0 : 16.0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
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
                  label: Text('Review'),
                  icon: Icon(Icons.rate_review),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            right: 16.0,
            bottom: _isFabExpanded ? 140.0 : 16.0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: _isFabExpanded ? 1.0 : 0.0,
              child: SizedBox(
                width: 150,
                child: FloatingActionButton.extended(
                  heroTag: 'guess',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    _toggleFab();
                  },
                  label: Text('Guess'),
                  icon: Icon(Icons.help_outline),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            right: 16.0,
            bottom: _isFabExpanded ? 80.0 : 16.0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
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
                  label: Text('Suggest'),
                  icon: Icon(Icons.edit),
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
      ),
    );
  }
}
