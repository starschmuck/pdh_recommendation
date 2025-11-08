import 'package:flutter/material.dart';
import 'package:pdh_recommendation/services/tasteful_twin_service.dart';

class TwinComparisonPopup extends StatelessWidget {
  final List<TwinComparisonRow> rows;
  final List<String> twinIds;

  const TwinComparisonPopup({required this.rows, required this.twinIds});

  /// Helper to shorten long userIds for display
  String shortenId(String id) {
    return id.length > 6 ? id.substring(0, 6) : id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tasteful Twins"),
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // allow horizontal scrolling
        child: DataTable(
          columnSpacing: 16.0, // reduce spacing between columns
          columns: [
            const DataColumn(
              label: Text("Me", style: TextStyle(fontSize: 12)),
            ),
            ...twinIds.map(
              (id) => DataColumn(
                label: Text(
                  shortenId(id), // show only first few chars
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          rows: rows.map((row) {
            return DataRow(
              color: row.highlight
                  ? MaterialStateProperty.all(Colors.yellow[100])
                  : null,
              cells: [
                DataCell(
                  Text(
                    row.meDisplay,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                ...twinIds.map(
                  (id) => DataCell(
                    Text(
                      row.twinRatings[id] ?? "-",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}