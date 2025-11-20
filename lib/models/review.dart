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
  final int likesCount;

  Review({
    required this.id,
    required this.userId,
    required this.meal,
    required this.rating,
    required this.reviewText,
    required this.timestamp,
    this.tags = const [],
    this.mediaUrl,
    this.likesCount = 0,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      meal: data['meal'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: data['reviewText'] ?? '',
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mediaUrl: data['mediaUrl'] as String?,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
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
      'likesCount': likesCount,
    };
  }

  Review copyWith({ int? likes, String? reviewText, /* other fields as needed */ }) {
    return Review(
      id: id,
      userId: userId,
      meal: meal,
      rating: rating,
      reviewText: reviewText ?? this.reviewText,
      timestamp: timestamp,
      tags: tags,
      mediaUrl: mediaUrl,
      likesCount: likesCount ?? likesCount,
    );
  }
}