import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailedSuggestionPopup extends StatefulWidget {
  final DocumentSnapshot doc;

  const DetailedSuggestionPopup({super.key, required this.doc});

  @override
  State<DetailedSuggestionPopup> createState() => _DetailedSuggestionPopupState();
}

class _DetailedSuggestionPopupState extends State<DetailedSuggestionPopup> {
  String authorName = 'Anonymous';
  int likes = 0;
  bool hasLiked = false;
  bool initialHasLiked = false;

  String _labelFor(String url) {
    try {
      final u = Uri.parse(url);
      if (u.hasAuthority && u.host.isNotEmpty) return 'Recipe: ${u.host}';
    } catch (_) {}
    return 'View recipe';
  }

  Future<void> _openRecipe(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid recipe link.')),
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open recipe link.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching link: $e')),
      );
    }
  }
  

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>? ?? {};
    final String? userId = data['userId'];

    // Initialize likes count
    likes = (data['likes'] ?? 0) as int;

    // Resolve author name
    if (userId != null && userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          setState(() {
            authorName = userData['name'] ?? 'Anonymous';
          });
        }
      });
    }

    // Check if current user has liked
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      FirebaseFirestore.instance
          .collection('suggestions')
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

    final title = data['title'] ?? 'Untitled';
    final suggestionText = data['suggestionText'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final dateTime = timestamp?.toDate();
    final recipeLink = (data['recipeLink'] as String?)?.trim(); // NEW

    final absoluteTime = dateTime != null
        ? DateFormat('MMM d, yyyy h:mm a').format(dateTime)
        : '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: const Color(0xFFF1F7FF), // soft blue
      insetPadding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7FF),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: const Color(0xFFDFEAFF)), // subtle border
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top row: Title + Author ---
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    authorName,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12.0),

              // --- Full suggestion text ---
              Text(
                suggestionText,
                style: const TextStyle(fontSize: 14.0),
              ),

              // --- Recipe link (if present) ---  NEW
              if (recipeLink != null && recipeLink.isNotEmpty) ...[
                const SizedBox(height: 12.0),
                GestureDetector(
                  onTap: () => _openRecipe(recipeLink),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 20, color: Colors.blue),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          _labelFor(recipeLink),
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12.0),

              // --- Like button row ---
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