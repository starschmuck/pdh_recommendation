import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showReviewPopup(BuildContext context, QueryDocumentSnapshot doc) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => ReviewPopup(doc: doc),
  );
}

class ReviewPopup extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const ReviewPopup({Key? key, required this.doc}) : super(key: key);

  @override
  _ReviewPopupState createState() => _ReviewPopupState();
}

class _ReviewPopupState extends State<ReviewPopup> {
  String reviewerName = 'Anonymous';
  bool _isLoaded = false;
  int likes = 0;
  bool hasLiked = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    final String? userId = data['userId'];

    if (data['likes'] != null) {
      likes = data['likes'];
    }

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
          })
          .catchError((_) {});
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
            });
          });
    }

    _isLoaded = true;
  }

  void _handleLikeToggle() async {
    final docRef = widget.doc.reference;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final likeRef = docRef.collection('likes').doc(currentUserId);
    final likeSnapshot = await likeRef.get();

    if (likeSnapshot.exists) {
      await likeRef.delete();
      await docRef.update({'likes': FieldValue.increment(-1)});
      setState(() {
        hasLiked = false;
        likes--;
      });
    } else {
      await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
      await docRef.update({'likes': FieldValue.increment(1)});
      setState(() {
        hasLiked = true;
        likes++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final String meal = data['meal'] ?? 'Unknown Meal';
    final double rating =
        data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0;
    final String reviewText = data['reviewText'] ?? 'No review provided.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoaded
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meal,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By $reviewerName',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 12),
                    Text(reviewText),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            hasLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_alt_outlined,
                            color: hasLiked ? Colors.blue : null,
                          ),
                          onPressed: _handleLikeToggle,
                        ),
                        Text('$likes likes'),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
