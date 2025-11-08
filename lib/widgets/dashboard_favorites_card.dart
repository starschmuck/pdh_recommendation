import 'package:flutter/material.dart';
import 'package:pdh_recommendation/main.dart';
import 'package:pdh_recommendation/screens/profile_screen.dart';
import 'package:provider/provider.dart'; // 👈 make sure this import matches your file path

class DashboardFavoritesCard extends StatelessWidget {
  final List<String> favorites;

  const DashboardFavoritesCard({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Provider.of<MyAppState>(context, listen: false).setSelectedIndex(3);
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
              "In case you forgot... (favorites)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 8.0),
            if (favorites.isEmpty)
              const Text(
                "None of your favorites are on today’s menu.",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...favorites.map(
                (meal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "• $meal",
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}