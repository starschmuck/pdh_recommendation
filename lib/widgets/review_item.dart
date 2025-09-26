import 'package:flutter/material.dart';
import 'star_rating.dart';

class ReviewItem extends StatelessWidget {
  final String title;
  final int stars;
  final String reviewText;
  final String reviewerName; // New parameter

  const ReviewItem({
    super.key,
    required this.title,
    required this.stars,
    required this.reviewText,
    required this.reviewerName, // New required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row for food name and star rating.
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4.0),
            StarRating(rating: stars.toDouble()),
            const SizedBox(width: 4.0),
          ],
        ),
        const SizedBox(height: 4.0),
        // Display reviewer name.
        Text(
          'by $reviewerName',
          style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0),
        ),
        const SizedBox(height: 4.0),
        // Row for review text.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: Text(reviewText))],
        ),
      ],
    );
  }
}
