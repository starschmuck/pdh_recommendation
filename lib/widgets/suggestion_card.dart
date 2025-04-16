import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'suggestion_item.dart';

class SuggestionCard extends StatelessWidget {
  /// A list of suggestion documents fetched from Firestore.
  final List<QueryDocumentSnapshot> suggestionDocs;

  const SuggestionCard({Key? key, required this.suggestionDocs})
    : super(key: key);

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
              "Guest Suggestions:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            suggestionDocs.isEmpty
                ? const Text("No suggestions available.")
                : Column(
                  children:
                      suggestionDocs
                          .map((doc) => SuggestionItem(doc: doc))
                          .toList(),
                ),
          ],
        ),
      ),
    );
  }
}
