import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/weekly_review_card.dart';
import 'package:pdh_recommendation/widgets/fab_cluster.dart';

class MainReviewScreen extends StatefulWidget {
  const MainReviewScreen({super.key});

  @override
  State<MainReviewScreen> createState() => _MainReviewScreenState();
}

class _MainReviewScreenState extends State<MainReviewScreen> {
  late final Stream<QuerySnapshot> _reviewsStream;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _reviewsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No reviews this week.'));
              }
              return WeeklyReviewCard(reviewDocs: snapshot.data!.docs);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const FabCluster(),
    );
  }
}