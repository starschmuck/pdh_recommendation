import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'individual_review_card.dart';
import 'review_video_player.dart';

class DetailedReviewPopup extends StatefulWidget {
  final DocumentSnapshot doc;

  const DetailedReviewPopup({Key? key, required this.doc}) : super(key: key);

  @override
  State<DetailedReviewPopup> createState() => _DetailedReviewPopupState();
}

class _DetailedReviewPopupState extends State<DetailedReviewPopup> {
  String reviewerName = 'Anonymous';
  int likes = 0;
  bool hasLiked = false;
  bool initialHasLiked = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>? ?? {};
    final String? userId = data['userId'];

    likes = (data['likes'] ?? 0) as int;

    if (userId != null && userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          setState(() {
            reviewerName = userData['name'] ?? 'Anonymous';
          });
        }
      });
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('reviews')
          .doc(widget.doc.id)
          .collection('likes')
          .doc(currentUserId)
          .get()
          .then((likeDoc) {
        setState(() {
          hasLiked = likeDoc.exists;
          initialHasLiked = likeDoc.exists;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _commitLikeChange();
  }

  Future<void> _commitLikeChange() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final docRef = widget.doc.reference;
    final likeRef = docRef.collection('likes').doc(currentUserId);

    if (hasLiked != initialHasLiked) {
      if (hasLiked) {
        await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
        await docRef.update({'likes': FieldValue.increment(1)});
      } else {
        await likeRef.delete();
        await docRef.update({'likes': FieldValue.increment(-1)});
      }
    }
  }

  void _toggleLike() {
    setState(() {
      if (hasLiked) {
        hasLiked = false;
        likes--;
      } else {
        hasLiked = true;
        likes++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>? ?? {};

    final meal = data['meal'] ?? 'Unknown Meal';
    final rating = (data['rating'] ?? 0).toDouble();
    final reviewText = (data['reviewText'] ?? '').toString();
    final mediaUrl = data['mediaUrl'] as String?;
    final bool isVideo = mediaUrl != null && mediaUrl.toLowerCase().contains('.mp4');
    if (mediaUrl != null) {
      print("Loading mediaUrl: $mediaUrl");
    }
    final tags = (data['tags'] as List<dynamic>?)
            ?.map((tag) => tag.toString())
            .toList() ??
        [];
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();

    final absoluteTime = dateTime != null
        ? DateFormat('MMM d, yyyy h:mm a').format(dateTime)
        : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top row: Meal name, star rating, reviewer name ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meal,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StarRating(rating: rating),
                  const SizedBox(width: 8.0),
                  Text(
                    reviewerName,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6.0),

              // --- Tags row (all tags, horizontally scrollable) ---
              if (tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tags.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.blueGrey.shade200),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11.0,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // --- Full review text ---
              Text(
                reviewText,
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 12.0),

              // --- Media row (image or video) ---
              if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: isVideo
                        ? ReviewVideoPlayer(url: mediaUrl) // custom widget below
                        : Image.network(
                            mediaUrl,
                            width: 250,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12.0),
              ],


              // --- Bottom row: absolute time (left), like button (right) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    absoluteTime,
                    style: const TextStyle(fontSize: 12.0, color: Colors.black45),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          hasLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_alt_outlined,
                          color: hasLiked ? Colors.blue : null,
                        ),
                        onPressed: _toggleLike,
                      ),
                      Text("$likes likes"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}