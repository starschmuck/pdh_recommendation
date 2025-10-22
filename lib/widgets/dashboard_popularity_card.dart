import 'package:flutter/material.dart';

class DashboardPopularityCard extends StatelessWidget {
  final String placement;     // e.g. "You’re 456 out of 4,324"
  final String likeSummary;   // e.g. "49 total review likes"

  const DashboardPopularityCard({
    super.key,
    required this.placement,
    required this.likeSummary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: replace with a proper popup widget later
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Popularity Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(placement),
                const SizedBox(height: 8),
                Text(likeSummary),
              ],
            ),
          ),
        );
      },
      child: Container(
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
              "Popularity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 8.0),

            Text(
              placement,
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              likeSummary,
              style: const TextStyle(
                fontSize: 13.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}