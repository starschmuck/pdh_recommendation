import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/individual_review_card.dart';

class ReviewResultsCard extends StatelessWidget {
  final List<DocumentSnapshot> reviewDocs;
  final String query;

  const ReviewResultsCard({
    Key? key,
    required this.reviewDocs,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section header ---
            Text(
              query.isEmpty
                  ? "All Reviews"
                  : 'Review Results for "$query"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // --- Results list ---
            if (reviewDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No reviews found.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewDocs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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