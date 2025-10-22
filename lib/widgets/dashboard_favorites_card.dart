import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class DashboardFavoritesCard extends StatelessWidget {
  final List<String> favorites;

  const DashboardFavoritesCard({super.key, required this.favorites});

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
              style: TextStyle(fontSize: 13.0, color: Colors.black54, fontStyle: FontStyle.italic),
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
    );
  }
}