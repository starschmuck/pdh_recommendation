import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Select an option',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}