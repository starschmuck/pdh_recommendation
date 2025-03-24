import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating; // Changed to double to allow fractional values
  final double size;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor(); // Number of full stars
    bool hasHalfStar = (rating - fullStars) >= 0.5; // Check if there's a half star
    int totalStars = hasHalfStar ? fullStars + 1 : fullStars; // Total filled spots

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber, size: size);
        } else {
          return Icon(Icons.star_border, color: Colors.grey, size: size);
        }
      }),
    );
  }
}
