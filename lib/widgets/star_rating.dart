import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final double size;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}