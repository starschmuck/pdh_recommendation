import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdh_recommendation/widgets/individual_review_card.dart';

/// The "big card" container for the Weekly Reviews section.
/// Displays a vertically stacked list of wide, short IndividualReviewCards.
class WeeklyReviewCard extends StatelessWidget {
  final List<DocumentSnapshot> reviewDocs;

  const WeeklyReviewCard({Key? key, required this.reviewDocs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Header ---
            const Text(
              "This Week's Reviews",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 12.0),

            // --- Vertical list of wide, short review cards ---
            // Use ListView.separated with shrinkWrap to avoid conflict with the parent scroll.
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviewDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final doc = reviewDocs[index];
                return IndividualReviewCard(doc: doc);
              },
            ),
          ],
        ),
      ),
    );
  }
}