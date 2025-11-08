import 'package:flutter/material.dart';
import '../services/crowd_rating_service.dart'; // where MealRating + service live

class DashboardCrowdCard extends StatefulWidget {
  const DashboardCrowdCard({super.key});

  @override
  State<DashboardCrowdCard> createState() => _DashboardCrowdCardState();
}

class _DashboardCrowdCardState extends State<DashboardCrowdCard> {
  late Future<_CrowdData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadCrowdData();
  }

  Future<_CrowdData> _loadCrowdData() async {
    final service = CrowdRatingService();

    // Top 3 for inline card
    final top3 = await service.getRatedMealsForToday(limit: 3);

    // Full list for leaderboard
    final allMeals = await service.getRatedMealsForToday(limit: 10);

    // Build leaderboard rows
    final rows = <Widget>[];
    for (int i = 0; i < allMeals.length; i++) {
      final rating = allMeals[i];
      rows.add(_leaderboardRow(i + 1, rating));
    }

    return _CrowdData(top3: top3, rows: rows);
  }

  static Widget _leaderboardRow(int rank, MealRating rating) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("#$rank", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(rating.mealName, textAlign: TextAlign.center),
          ),
          Text(rating.averageRating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CrowdData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(const ["Loading…"]);
        }
        if (snapshot.hasError) {
          return _buildCard(const ["Error loading crowd favorites"]);
        }
        final data = snapshot.data!;
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => LeaderboardPopup(
                title: "Crowd Favorites Leaderboard",
                rows: data.rows,
              ),
            );
          },
          child: _buildCard(data.top3.map((m) => m.mealName).toList()),
        );
      },
    );
  }

  Widget _buildCard(List<String> topMeals) {
    return Container(
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
            "What the crowd thinks...",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
          ),
          const SizedBox(height: 8.0),
          if (topMeals.isEmpty)
            const Text(
              "No crowd favorites yet. Check back later!",
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...topMeals.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  "• $item",
                  style: const TextStyle(fontSize: 13.0, color: Colors.black87),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CrowdData {
  final List<MealRating> top3;
  final List<Widget> rows;
  _CrowdData({required this.top3, required this.rows});
}

class LeaderboardPopup extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const LeaderboardPopup({super.key, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}