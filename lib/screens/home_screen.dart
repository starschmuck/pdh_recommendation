import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/review_card.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/action_button.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the app state
    final appState = Provider.of<MyAppState>(context);

    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: appState.isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reviews Card
                    ReviewCard(),
                    SizedBox(height: 16.0),
                    
                    // Guest Suggestions Card
                    SuggestionCard(),
                    SizedBox(height: 16.0),
                    
                    // Action Buttons
                    ActionButton(
                      text: 'REVIEW YOUR DISH FOR POINTS',
                      onPressed: () {
                        // Handle review action
                      },
                      isBold: true,
                    ),
                    SizedBox(height: 8.0),
                    ActionButton(
                      text: 'Guess Tomorrow\'s Best Dish',
                      onPressed: () {
                        // Handle guess action
                      },
                    ),
                    SizedBox(height: 8.0),
                    ActionButton(
                      text: 'Suggest a New Dish',
                      onPressed: () {
                        // Handle suggest action
                      },
                    ),
                  ],
                ),
              ),
            ),
      // Keep the refresh functionality from original code
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          // Manually refresh data
          appState.fetchData();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}