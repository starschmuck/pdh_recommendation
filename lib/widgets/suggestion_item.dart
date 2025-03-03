import 'package:flutter/material.dart';
import 'star_rating.dart';

class SuggestionItem extends StatelessWidget {
  final String title;
  final int stars;

  const SuggestionItem({
    Key? key,
    required this.title,
    required this.stars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        StarRating(rating: stars),
      ],
    );
  }
}