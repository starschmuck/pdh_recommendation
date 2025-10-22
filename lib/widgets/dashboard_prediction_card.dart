import 'package:flutter/material.dart';

class DashboardPredictionsCard extends StatelessWidget {
  final String placement;   // e.g. "You’re 123 out of 4,234"
  final String accuracy;    // e.g. "99% accuracy"

  const DashboardPredictionsCard({
    super.key,
    required this.placement,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: replace with a proper popup widget later
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Predictions Details"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(placement),
                const SizedBox(height: 8),
                Text(accuracy),
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
              "Predictions",
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
              accuracy,
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