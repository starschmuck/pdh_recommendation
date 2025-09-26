import 'package:flutter/material.dart';
import 'filter_dropdown.dart';
import 'result_item.dart';

class SearchResultsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool hasNoResults;
  final bool showStars; // New parameter to control star drawing
  final bool enableRatingFilter;
  final int selectedRating;
  final ValueChanged<int?>? onRatingChanged;
  final ValueChanged<Map<String, dynamic>>? onItemTap;

  const SearchResultsSection({
    Key? key,
    required this.title,
    required this.items,
    this.hasNoResults = false,
    this.showStars = true,
    this.enableRatingFilter = false,
    this.selectedRating = 0,
    this.onRatingChanged,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.brown.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          if (enableRatingFilter) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                'Filter by rating:',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
              child: FilterDropdown(
                selectedRating: selectedRating,
                onChanged: onRatingChanged ?? (_) {},
              ),
            ),
          ],
          // No results message or list of results
          hasNoResults
              ? Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'No results found',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              )
              : Column(
                children:
                    items
                        .map(
                          (item) => ResultItem(
                            name: item['name'],
                            // If stars aren't to be drawn, rating is irrelevant.
                            // You might pass 0 or any value since ResultItem will check showStars.
                            rating: showStars ? (item['rating'] ?? 0) : 0,
                            showStars: showStars, // Pass the flag to ResultItem
                            onTap: onItemTap != null
                                ? () => onItemTap!(item)
                                : null,
                          ),
                        )
                        .toList(),
              ),
          // Pagination indicator
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Icon(Icons.more_horiz, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
