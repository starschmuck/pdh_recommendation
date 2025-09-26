import 'package:flutter/material.dart';

class RankingTile extends StatelessWidget {
  final String title;
  final String rankPrefix;
  final String rankSuffix;
  final String additionalInfo;
  final bool showVoteButton;
  
  // Constructor
  const RankingTile({
    super.key,
    required this.title,
    required this.rankPrefix,
    required this.rankSuffix,
    required this.additionalInfo,
    this.showVoteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.brown.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text("- $rankPrefix ", style: TextStyle(color: Colors.white)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.green,
                      child: Text("1", style: TextStyle(color: Colors.white)),
                    ),
                    Text(" $rankSuffix", style: TextStyle(color: Colors.white)),
                  ],
                ),
                Text("- $additionalInfo", style: TextStyle(color: Colors.white)),
                Text("View Leaderboard", style: TextStyle(color: Colors.blue.shade200)),
              ],
            ),
          ),
          if (showVoteButton)
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.brown.shade800,
              child: Column(
                children: [
                  Text("VOTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("NOW!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}