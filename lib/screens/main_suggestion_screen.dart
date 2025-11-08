import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/weekly_suggestion_card.dart';
import 'package:pdh_recommendation/widgets/fab_cluster.dart';

class MainSuggestionScreen extends StatefulWidget {
  const MainSuggestionScreen({super.key});

  @override
  State<MainSuggestionScreen> createState() => _MainSuggestionScreenState();
}

class _MainSuggestionScreenState extends State<MainSuggestionScreen> {
  late final Stream<QuerySnapshot> _suggestionsStream;

  @override
  void initState() {
    super.initState();
    final weekAgo = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 7)),
    );
    _suggestionsStream = FirebaseFirestore.instance
        .collection('suggestions')
        .where('timestamp', isGreaterThanOrEqualTo: weekAgo)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _suggestionsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No suggestions this week.'));
              }
              return WeeklySuggestionCard(suggestionDocs: snapshot.data!.docs);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FabCluster(),
    );
  }
}