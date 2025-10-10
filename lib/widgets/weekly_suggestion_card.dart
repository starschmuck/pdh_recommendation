import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'individual_suggestion_card.dart';

/// The "big card" container for the Weekly Suggestions section.
/// Displays a vertically stacked list of IndividualSuggestionCards.
class WeeklySuggestionCard extends StatelessWidget {
  final List<DocumentSnapshot> suggestionDocs;

  const WeeklySuggestionCard({Key? key, required this.suggestionDocs})
      : super(key: key);

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
            const Text(
              "This Week's Suggestions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 12.0),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestionDocs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final doc = suggestionDocs[index];
                return IndividualSuggestionCard(doc: doc);
              },
            ),
          ],
        ),
      ),
    );
  }
}