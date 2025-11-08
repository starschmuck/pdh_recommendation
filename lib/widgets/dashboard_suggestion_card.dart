import 'package:flutter/material.dart';
import 'package:pdh_recommendation/services/tasteful_twin_service.dart';
import 'package:pdh_recommendation/widgets/twin_comparison_popup.dart';

class DashboardSuggestionCard extends StatelessWidget {
  final List<String> suggestions;
  final bool isLoading;
  final String userId; // add userId so we know who "Me" is

  const DashboardSuggestionCard({
    super.key,
    required this.suggestions,
    required this.userId,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: suggestions.isEmpty
          ? null // disable tap if no suggestions
          : () async {
              // fetch comparison data
              final service = TastefulTwinService();
              final rows = await service.getTwinComparisonTable(userId);

              // extract twinIds from rows (first 3 highlight rows)
              final twinIds = rows
                  .where((r) => r.highlight)
                  .map((r) => r.twinRatings.keys)
                  .expand((ids) => ids)
                  .toSet()
                  .toList();

              showDialog(
                context: context,
                builder: (_) => TwinComparisonPopup(
                  rows: rows,
                  twinIds: twinIds,
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
            const Text("What we suggest...",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            if (isLoading)
              const Text("Loading…",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic))
            else if (suggestions.isEmpty)
              const Text("No suggestions yet. Rate more meals!",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic))
            else
              ...suggestions.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• $s",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87)),
                  )),
          ],
        ),
      ),
    );
  }
}
