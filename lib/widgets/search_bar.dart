import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey),
              ),
            ),
            child: Icon(Icons.search, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}