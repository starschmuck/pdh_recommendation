import 'package:flutter/material.dart';
import 'package:pdh_recommendation/widgets/review_item_with_reviewer_name.dart';
import 'filter_dropdown.dart';
import 'result_item.dart';

class SearchResultsSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool hasNoResults;
  final bool showStars; // parameter to control star drawing
  final bool isReviewSection; 

  const SearchResultsSection({
    super.key,
    required this.title,
    required this.items,
    this.hasNoResults = false,
    this.showStars = true,
    this.isReviewSection = false,
  });

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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'Filter by:',
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
            child: FilterDropdown(),
          ),
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
                  children: items.map((item) {
                    if (isReviewSection) {
                      // 👇 assumes you stored the Firestore doc in fetchReviews
                      return ReviewItemWithReviewerName(doc: item['doc']);
                    } else {
                      return ResultItem(
                        name: item['name'],
                        rating: showStars ? (item['rating'] ?? 0) : 0,
                        showStars: showStars,
                      );
                    }
                  }).toList(),
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
