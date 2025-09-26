import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'review_card.dart'; // import your prebuilt card

class ReviewItemWithReviewerName extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const ReviewItemWithReviewerName({super.key, required this.doc});

  Future<List<String>> getReviewMediaUrls(String uid, String reviewId) async {
    final storageRef = FirebaseStorage.instance.ref()
        .child('reviews')
        .child(uid)
        .child(reviewId);

    final result = await storageRef.listAll();
    return Future.wait(result.items.map((ref) => ref.getDownloadURL()));
  }

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.avi');
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = doc['timestamp'] != null
        ? (doc['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final hour = timestamp.hour > 12
        ? timestamp.hour - 12
        : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final ampm = timestamp.hour >= 12 ? "PM" : "AM";
    final formattedTime =
        "${timestamp.month}/${timestamp.day}/${timestamp.year} $hour:${timestamp.minute.toString().padLeft(2, '0')} $ampm";

    final rating = doc['rating'] ?? 0;
    final meal = doc['meal'] ?? '';
    final reviewText = doc['reviewText'] ?? '';
    final tags = List<String>.from(doc['tags'] ?? []);

    // Card UI for the list
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        // Show popup with ReviewCard using this single review
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ReviewCard(
                    reviewDocs: [doc], // wrap single doc in list
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal title
              Text(
                meal,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),

              // Rating stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 6),

              // Review text preview
              Text(
                reviewText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),

              // Timestamp
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Keep your VideoPlayerWidget unchanged
class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: VideoProgressIndicator(_controller, allowScrubbing: true),
          ),
          Center(
            child: IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
