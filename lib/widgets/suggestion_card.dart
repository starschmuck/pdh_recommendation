import 'package:flutter/material.dart';
import 'suggestion_item.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Guest Suggestions:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            
            // Suggestion Items - These could be loaded from database later
            SuggestionItem(title: 'Shrimp Fried Rice', stars: 4),
            Divider(),
            
            SuggestionItem(title: 'Cheeseburger', stars: 2),
            Divider(),
            
            SuggestionItem(title: 'Teriyaki Wings', stars: 3),
            Divider(),
            
            SuggestionItem(title: 'Lasagna', stars: 4),
            Divider(),
            
            SuggestionItem(title: 'Mashed Potatoes', stars: 5),
          ],
        ),
      ),
    );
  }
}