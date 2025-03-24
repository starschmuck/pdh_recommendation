import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/star_rating.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.primary,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PROFILE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Icon(Icons.person)
                        ]
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome, user!',
                          style: TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold
                                ),
                          ),
                      ),
                      ExpansionTile(
                        title: Text('My Recent Reviews',
                        style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Review 1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              StarRating(rating: 5),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Review 2',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              StarRating(rating: 2.5),
                            ],
                          ), 
                        ],
                      ),
                      ExpansionTile(
                        title: Text(
                          'My Recent Suggestions',
                          style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suggestion 1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              StarRating(rating: 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Suggestion 2',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              StarRating(rating: 0.5),
                            ],
                          ), 
                        ],
                      ),
                    ],
                  ),
                ),
              
            )
          ),
        ),
      ),
    ); 
  }
}