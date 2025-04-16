import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'review_item.dart';

class ReviewItemWithReviewerName extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const ReviewItemWithReviewerName({Key? key, required this.doc})
    : super(key: key);

  @override
  _ReviewItemWithReviewerNameState createState() =>
      _ReviewItemWithReviewerNameState();
}

class _ReviewItemWithReviewerNameState
    extends State<ReviewItemWithReviewerName> {
  String reviewerName = 'Anonymous';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Extract the userId from the review document.
    final data = widget.doc.data() as Map<String, dynamic>;
    final String userId = data['userId'] ?? '';

    // Fetch the reviewer’s name from the "users" collection.
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((DocumentSnapshot docSnapshot) {
          if (docSnapshot.exists) {
            final userData = docSnapshot.data() as Map<String, dynamic>;
            setState(() {
              reviewerName = userData['name'] ?? 'Anonymous';
              _isLoaded = true;
            });
          } else {
            setState(() {
              reviewerName = 'Anonymous';
              _isLoaded = true;
            });
          }
        })
        .catchError((error) {
          // In case of an error, we keep the default name.
          setState(() {
            reviewerName = 'Anonymous';
            _isLoaded = true;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // Extract review fields from the document.
    final data = widget.doc.data() as Map<String, dynamic>;
    final String meal = data['meal'] ?? 'Unknown Meal';
    final double rating =
        data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0;
    final String reviewText = data['reviewText'] ?? '';
    final bool hasMoreButton = data['hasMoreButton'] ?? false;

    return Column(
      children: [
        ReviewItem(
          title: meal,
          reviewerName: reviewerName,
          stars: rating.toInt(),
          reviewText: reviewText,
        ),
        const Divider(),
      ],
    );
  }
}
