import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/recommendation_tile.dart';
import 'package:pdh_recommendation/widgets/ranking_tile.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'What\'s Tasty Today?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                  RecommendationTile(
                    title: 'What we suggest...', 
                    items: ["Buffalo Chicken Wrap", "BBQ Chicken"]
                  ),
            
                  RecommendationTile(
                    title: 'What the crowd thinks...',
                    items: ["Chicken Nuggets", "Broccoli Cheddar Soup"],
                  ),
            
                  RecommendationTile(
                    title: 'In case you forgot... (here are some faves)',
                    items: ['Chicken Tenders', "Spaghetti & Meatballs"],
                  ),
            
                  RecommendationTile(
                    title: 'Your Tasteful Twin also likes...',
                    items: ['Chicken Parmesan', 'Chicken Alfredo'],
                  )
                ]
              ),
                    ),
          ), 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'How am I ranked?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
            
                  RankingTile(
                    title: 'Predictions',
                    rankPrefix: 'You\'re',
                    rankSuffix: 'out of 4,234',
                    additionalInfo: '99% accuracy',
                    showVoteButton: true,
                  ),
            
                  RankingTile(
                    title: "Reviews", 
                    rankPrefix: "You're", 
                    rankSuffix: "out of 4,324", 
                    additionalInfo: "49 total review likes",
                    showVoteButton: false,
                  ),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}