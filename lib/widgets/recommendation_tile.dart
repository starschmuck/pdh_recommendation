import 'package:flutter/material.dart';

class RecommendationTile extends StatelessWidget {
  final String title;
  final List<String> items;
  
  // Constructor
  const RecommendationTile({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.brown.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          ),
          SizedBox(height: 4),
          ...items.map((item) => Row(
            children: [
              Text("- $item", style: TextStyle(color: Colors.white)),
              SizedBox(width: 5),
              // Star rating here
              Row(children: List.generate(5, (index) => 
                Icon(Icons.star, size: 14, color: Colors.yellow))),
              Text(" [See More]", style: TextStyle(color: Colors.blue.shade200)),
            ],
          )),
        ],
      ),
    );
  }
}