import 'package:flutter/material.dart';

class DashboardRealizedCard extends StatelessWidget {
  final List<String> realizedSuggestions;

  const DashboardRealizedCard({
    super.key,
    required this.realizedSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: replace with a proper popup widget later
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Realized Suggestions"),
            content: realizedSuggestions.isEmpty
                ? const Text("No realized suggestions today.")
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: realizedSuggestions
                        .map((s) => Text("• $s"))
                        .toList(),
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
              "Suggestions That Came True",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 8.0),

            if (realizedSuggestions.isEmpty)
              const Text(
                "None of your suggestions have been realized yet.",
                style: TextStyle(fontSize: 13.0, color: Colors.black54),
              )
            else
              ...realizedSuggestions.map(
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