import 'package:flutter/material.dart';

class ResultItem extends StatelessWidget {
  final String name;
  final int rating;
  final String stats;

  const ResultItem({
    Key? key,
    required this.name,
    required this.rating,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Text(
            '- $name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 5),
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
          if (stats.isNotEmpty)
            Text(
              ' $stats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}