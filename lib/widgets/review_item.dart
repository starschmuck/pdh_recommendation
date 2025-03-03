import 'package:flutter/material.dart';
import 'star_rating.dart';

class ReviewItem extends StatelessWidget {
  final String title;
  final int stars;
  final String ratingText;
  final String reviewText;
  final bool hasMoreButton;

  const ReviewItem({
    Key? key,
    required this.title,
    required this.stars,
    required this.ratingText,
    required this.reviewText,
    this.hasMoreButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 4.0),
            StarRating(rating: stars),
            SizedBox(width: 4.0),
            Text(
              ratingText,
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(reviewText),
            ),
            if (hasMoreButton)
              TextButton(
                onPressed: () {
                  // Handle see more action
                },
                child: Text(
                  '(See more)',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
          ],
        ),
      ],
    );
  }
}