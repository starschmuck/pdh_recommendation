import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_results_section.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchBarWidget(),
                SizedBox(height: 12),
                SearchResultsSection(
                  title: 'Review Results for "eggs"',
                  items: [
                    {'name': 'Scrambled Eggs', 'rating': 4, 'stats': '(81/100)'},
                    {'name': 'Omelettes', 'rating': 3, 'stats': '(54/100)'},
                    {'name': 'Hard Boiled Eggs', 'rating': 3, 'stats': '(61/100)'},
                    {'name': 'Chicken Fried Rice', 'rating': 4, 'stats': '(91/100)'},
                    {'name': 'Scrambled Eggs', 'rating': 4, 'stats': '(81/100)'},
                    {'name': 'Scrambled Eggs', 'rating': 3, 'stats': '(71/100)'},
                    {'name': 'Egg & Cheese Bagel', 'rating': 4, 'stats': '(87/100)'},
                    {'name': 'Omelettes', 'rating': 3, 'stats': '(54/100)'},
                    {'name': 'Hard Boiled Eggs', 'rating': 4, 'stats': '(77/100)'},
                  ],
                ),
                SizedBox(height: 12),
                SearchResultsSection(
                  title: 'Suggestion Results for "eggs"',
                  items: [
                    {'name': 'Eggs Benedict', 'rating': 5, 'stats': ''},
                    {'name': 'Omelettes', 'rating': 3, 'stats': ''},
                    {'name': 'Egg & Cheese Croissant', 'rating': 5, 'stats': ''},
                    {'name': 'Scrambled Eggs', 'rating': 4, 'stats': ''},
                    {'name': 'Egg & Cheese Bagel', 'rating': 4, 'stats': ''},
                    {'name': 'Breakfast Bowl', 'rating': 4, 'stats': ''},
                  ],
                ),
                SizedBox(height: 12),
                SearchResultsSection(
                  title: 'User Results for "eggs"',
                  items: [],
                  hasNoResults: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}