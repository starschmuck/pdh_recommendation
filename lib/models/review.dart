import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String meal;       
  final double rating;
  final String reviewText;  
  final List<String> tags;
  final String? mediaUrl;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.userId,
    required this.meal,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
    this.tags = const [],
    this.mediaUrl,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      meal: data['meal'] ?? '',
      rating: (data['rating'] as num).toDouble(),
      reviewText: data['reviewText'] ?? '',
      tags: (data['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mediaUrl: data['mediaUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'meal': meal,
      'rating': rating,
      'reviewText': reviewText,
      'tags': tags,
      'mediaUrl': mediaUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}