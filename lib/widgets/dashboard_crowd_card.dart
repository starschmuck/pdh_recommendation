import 'package:flutter/material.dart';

class DashboardCrowdCard extends StatelessWidget {
  final List<String> crowdFavorites;

  const DashboardCrowdCard({
    super.key,
    required this.crowdFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What the crowd thinks...",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),

          if (crowdFavorites.isEmpty)
            const Text(
              "No crowd favorites yet. Check back later!",
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...crowdFavorites.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  "• $item",
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}