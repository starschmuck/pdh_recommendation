import 'package:flutter/material.dart';

class DashboardSuggestionCard extends StatelessWidget {
  final List<String> suggestions;

  const DashboardSuggestionCard({
    super.key,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: suggestions.isEmpty
          ? null // disable tap if no suggestions
          : () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Detailed Suggestions"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: suggestions.map((s) => Text("• $s")).toList(),
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
              "What we suggest...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 8.0),

            if (suggestions.isEmpty)
              const Text(
                "No suggestions yet. Rate more meals!",
                style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...suggestions.map(
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
      ),
    );
  }
}