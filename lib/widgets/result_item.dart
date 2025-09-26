import 'package:flutter/material.dart';

class ResultItem extends StatelessWidget {
  final String name;
  final int rating;
  final bool showStars;
  final VoidCallback? onTap;

  const ResultItem({
    Key? key,
    required this.name,
    required this.rating,
    this.showStars = true, // defaults to true if not provided
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Text('- $name', style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(width: 5),
              // Conditionally display the star rating.
              if (showStars)
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.yellow,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
