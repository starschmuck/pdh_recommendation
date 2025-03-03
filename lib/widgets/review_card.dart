import 'package:flutter/material.dart';
import 'review_item.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({Key? key}) : super(key: key);

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
              "This week's reviews:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            
            // Review Items - These could be loaded from database later
            ReviewItem(
              title: 'Cheese Pizza',
              stars: 2,
              ratingText: '(25.25 of 5 Stars)',
              reviewText: 'Last Franklin: The pizza was very greasy and a little cold. The crust was also burnt and not enjoyable.',
              hasMoreButton: true,
            ),
            Divider(),
            
            ReviewItem(
              title: 'Spaghetti',
              stars: 5,
              ratingText: '(5 of 5 Stars)',
              reviewText: 'Anthony Hordesky: My spaghetti was great. The noodles were cooked perfectly and the sauce was very flavorful.',
            ),
            Divider(),
            
            ReviewItem(
              title: 'Lasagna',
              stars: 4,
              ratingText: '(4.5 of 5 Stars)',
              reviewText: 'Alex Laureano: I was a fan of the lasagna. It was a little saltier than I like, but I would still eat it again.',
            ),
            Divider(),
            
            ReviewItem(
              title: 'Mac N\' Cheese',
              stars: 1,
              ratingText: '(1 of 5 Stars)',
              reviewText: 'Ilahao Shu: I liked this dish. The noodles were a good choice for this dish and the cheese used was',
              hasMoreButton: true,
            ),
          ],
        ),
      ),
    );
  }
}