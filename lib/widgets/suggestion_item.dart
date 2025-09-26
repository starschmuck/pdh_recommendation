import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdh_recommendation/widgets/star_rating.dart';
import 'package:pdh_recommendation/widgets/suggestion_popup.dart';

class SuggestionItem extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const SuggestionItem({super.key, required this.doc});

  @override
  _SuggestionItemState createState() => _SuggestionItemState();
}

class _SuggestionItemState extends State<SuggestionItem> {
  String reviewerName = 'Anonymous';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    final String userId = data['userId'] ?? '';
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
          setState(() {
            reviewerName = 'Anonymous';
            _isLoaded = true;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // Extract suggestion fields from the document.
    final data = widget.doc.data() as Map<String, dynamic>;
    final String title = data['title'] ?? 'No Title';
    final String suggestionText = data['suggestionText'] ?? '';
    // Convert rating from double to int (defaults to 0 if missing).
    final double ratingDouble =
        data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0;
    final int stars = ratingDouble.toInt();

    return GestureDetector(
      onTap: () => showSuggestionPopup(context, widget.doc),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row for suggestion title and star rating.
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                StarRating(rating: 0.0),
                const SizedBox(width: 5),
              ],
            ),
            const SizedBox(height: 4.0),
            // Display the submitter's name above the suggestion text.
            Text(
              'by $reviewerName',
              style: const TextStyle(
                color: Colors.black,
                fontStyle: FontStyle.italic,
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 4.0),
            // Suggestion text (if provided).
            if (suggestionText.isNotEmpty)
              Text(
                suggestionText,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
