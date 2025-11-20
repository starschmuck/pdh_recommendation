import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/individual_suggestion_card.dart';

class SuggestionResultsCard extends StatelessWidget {
  final List<DocumentSnapshot> suggestionDocs;
  final String query;

  const SuggestionResultsCard({
    super.key,
    required this.suggestionDocs,
    required this.query,
  });

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
                  ? "All Suggestions"
                  : 'Suggestion Results for "$query"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // --- Results list ---
            if (suggestionDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No suggestions found.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestionDocs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
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