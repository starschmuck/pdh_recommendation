import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_item_with_reviewer_name.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ReviewCard extends StatelessWidget {
  /// A list of review documents fetched from Firestore.
  final List<QueryDocumentSnapshot> reviewDocs;

  const ReviewCard({super.key, required this.reviewDocs});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This week's reviews:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            reviewDocs.isEmpty
                ? const Text("No reviews available.")
                : Column(
                  children:
                      reviewDocs
                          .map((doc) => ReviewItemWithReviewerName(doc: doc))
                          .toList(),
                ),
          ],
        ),
      ),
    );
  }
}
