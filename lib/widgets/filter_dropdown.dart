import 'package:flutter/material.dart';

/// Dropdown used for filtering review results by minimum star rating.
class FilterDropdown extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int?> onChanged;

  const FilterDropdown({
    super.key,
    required this.selectedRating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      child: DropdownButton<int>(
        value: selectedRating,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 0, child: Text('All ratings')),
          DropdownMenuItem(value: 1, child: Text('1+ stars')),
          DropdownMenuItem(value: 2, child: Text('2+ stars')),
          DropdownMenuItem(value: 3, child: Text('3+ stars')),
          DropdownMenuItem(value: 4, child: Text('4+ stars')),
          DropdownMenuItem(value: 5, child: Text('5 stars')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}