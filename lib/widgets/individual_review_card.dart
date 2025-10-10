import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdh_recommendation/widgets/detailed_review_popup.dart';
import 'package:timeago/timeago.dart' as timeago;

class IndividualReviewCard extends StatefulWidget {
  final DocumentSnapshot doc;

  const IndividualReviewCard({Key? key, required this.doc}) : super(key: key);

  @override
  State<IndividualReviewCard> createState() => _IndividualReviewCardState();
}

class _IndividualReviewCardState extends State<IndividualReviewCard> {
  String reviewerName = 'Anonymous';

  @override
  void initState() {
    super.initState();
    _resolveReviewerName();
  }

  void _resolveReviewerName() async {
    final data = widget.doc.data() as Map<String, dynamic>? ?? {};
    final String? userId = data['userId'];

    if (userId != null && userId.isNotEmpty) {
      try {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            reviewerName = userData['name'] ?? 'Anonymous';
          });
        }
      } catch (_) {
        // leave as Anonymous if lookup fails
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>? ?? {};

    final meal = data['meal'] ?? 'Unknown Meal';
    final rating = (data['rating'] ?? 0).toDouble();
    final reviewText = (data['reviewText'] ?? '').toString();
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final tags = (data['tags'] as List<dynamic>?)
            ?.map((tag) => tag.toString())
            .toList() ??
        [];

    final relativeTime =
        dateTime != null ? timeago.format(dateTime, locale: 'en_short') : '';

    final likes = (data['likes'] ?? 0) as int;

    final String? mediaUrl = data['mediaUrl'] as String?;
    final bool hasMedia = mediaUrl != null && mediaUrl.isNotEmpty;


    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DetailedReviewPopup(doc: widget.doc),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top row: meal name, optional image icon, star rating, reviewer name ---
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        meal,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasMedia) ...[
                      const SizedBox(width: 4.0),
                      const Icon(Icons.image_outlined,
                          size: 16, color: Colors.black45),
                    ],
                  ],
                ),
              ),
              StarRating(rating: rating),
              const SizedBox(width: 8.0),
              Text(
                reviewerName,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),


            const SizedBox(height: 4.0),

            // --- Tags row ---
            if (tags.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: tags.take(3).map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6.0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.blueGrey.shade200),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 6.0),

            // --- Snippet row ---
            Text(
              reviewText.trim().replaceAll('\n', ' '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.0, color: Colors.black87),
            ),

            const SizedBox(height: 6.0),

            // --- Bottom row: relative time (left), likes (right, static) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  relativeTime,
                  style: const TextStyle(fontSize: 11.0, color: Colors.black45),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      "$likes",
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Star rating widget (unchanged)
class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;

  const StarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starIndex = index + 1;
        if (rating >= starIndex) {
          return Icon(Icons.star, color: color, size: 16);
        } else if (rating > starIndex - 1 && rating < starIndex) {
          return Icon(Icons.star_half, color: color, size: 16);
        } else {
          return Icon(Icons.star_border, color: color, size: 16);
        }
      }),
    );
  }
}