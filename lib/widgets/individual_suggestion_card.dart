import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'detailed_suggestion_popup.dart';

class IndividualSuggestionCard extends StatelessWidget {
  final DocumentSnapshot doc;

  const IndividualSuggestionCard({Key? key, required this.doc})
      : super(key: key);

  Future<String> _fetchAuthorName(String? userId) async {
    if (userId == null || userId.isEmpty) return 'Anonymous';
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['name'] ?? 'Anonymous';
      }
    } catch (_) {}
    return 'Anonymous';
  }

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final title = data['title'] ?? 'Untitled';
    final suggestionText = data['suggestionText'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final relativeTime =
        dateTime != null ? timeago.format(dateTime, locale: 'en_short') : '';

    final likes = (data['likes'] ?? 0) as int;
    final userId = data['userId'] as String?;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => DetailedSuggestionPopup(doc: doc),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top row: title + author ---
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FutureBuilder<String>(
                  future: _fetchAuthorName(userId),
                  builder: (context, snapshot) {
                    final authorName = snapshot.data ?? '...';
                    return Text(
                      authorName,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 6.0),

            // --- Suggestion text snippet ---
            Text(
              suggestionText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.0, color: Colors.black87),
            ),

            const SizedBox(height: 6.0),

            // --- Bottom row: relative time (left), likes (right, static) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  relativeTime,
                  style: const TextStyle(fontSize: 11.0, color: Colors.black45),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      "$likes",
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}