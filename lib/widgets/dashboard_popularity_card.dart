import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPopularityCard extends StatefulWidget {
  const DashboardPopularityCard({super.key});

  @override
  State<DashboardPopularityCard> createState() => _DashboardPopularityCardState();
}

class _DashboardPopularityCardState extends State<DashboardPopularityCard> {
  late Future<_PopularityData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadUserPopularityData();
  }

  Future<_PopularityData> _loadUserPopularityData() async {
    final db = FirebaseFirestore.instance;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return _PopularityData(
        placement: "Not signed in",
        likeSummary: "",
        rows: const [],
      );
    }

    // --- Top 10 ---
    final topSnap = await db
        .collection('userPopularity')
        .orderBy('totalLikes', descending: true)
        .limit(10)
        .get();
    final topDocs = topSnap.docs;
    String topUsername = "";
    if (topDocs.isNotEmpty) {
      final topData = topDocs.first.data();
      topUsername = topData['username'] ?? topDocs.first.id;
    }
    final topUserIds = topDocs.map((d) => d.id).toSet();

    // --- Current user ---
    final meSnap = await db.collection('userPopularity').doc(currentUserId).get();
    final meData = meSnap.data() as Map<String, dynamic>?;
    final myLikes = (meData?['totalLikes'] as num?)?.toInt() ?? 0;

    // --- Rank ---
    int myRank;
    if (topUserIds.contains(currentUserId)) {
      // find index in topDocs
      myRank = topDocs.indexWhere((d) => d.id == currentUserId) + 1;
    } else {
      final higherSnap = await db
          .collection('userPopularity')
          .where('totalLikes', isGreaterThan: myLikes)
          .count()
          .get();
      final higher = higherSnap.count ?? 0;
      myRank = higher + 1;
    }

    // --- Total users ---
    final totalSnap = await db.collection('userPopularity').count().get();
    final totalUsers = totalSnap.count ?? 0;

    // --- Build rows for popup ---
    final rows = <Widget>[];
    for (int i = 0; i < topDocs.length; i++) {
      final d = topDocs[i];
      final data = d.data();
      final uid = d.id;
      final username = data['username'] ?? uid;
      final likes = data['totalLikes'] ?? 0;
      final isMe = uid == currentUserId;
      rows.add(_leaderboardRow(i + 1, username, likes, isMe));
    }
    if (!topUserIds.contains(currentUserId)) {
      rows.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Text("…", style: TextStyle(color: Colors.grey)),
      ));
      rows.add(_leaderboardRow(myRank, meData?['username'] ?? "You", myLikes, true));
    }

    return _PopularityData(
      placement: "You’re $myRank out of $totalUsers",
      likeSummary: "Top user: $topUsername",
      rows: rows,
    );
  }

  static Widget _leaderboardRow(int rank, String username, int likes, bool isMe) {
    return Container(
      color: isMe ? Colors.blue.withOpacity(0.1) : null,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("#$rank", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              username,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text("$likes"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PopularityData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard("Loading…", "");
        }
        if (snapshot.hasError) {
          return _buildCard("Error", snapshot.error.toString());
        }
        final data = snapshot.data!;
        return InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => LeaderboardPopup(rows: data.rows),
            );
          },
          child: _buildCard(data.placement, data.likeSummary),
        );
      },
    );
  }

  Widget _buildCard(String placement, String likeSummary) {
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
            "Popularity",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            placement,
            style: const TextStyle(
              fontSize: 13.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            likeSummary,
            style: const TextStyle(
              fontSize: 13.0,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardPopup extends StatelessWidget {
  final List<Widget> rows;
  const LeaderboardPopup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Leaderboard",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _PopularityData {
  final String placement;
  final String likeSummary;
  final List<Widget> rows;
  _PopularityData({
    required this.placement,
    required this.likeSummary,
    required this.rows,
  });
}