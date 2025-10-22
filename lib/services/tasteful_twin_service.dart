import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../models/review.dart';
import 'dart:math';

class TastefulTwinService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generates up to 3 meal recommendations for the given user
  /// based on similarity with other users' reviews.
  Future<List<Meal>> getRecommendationsForUser(String userId) async {
    // Fetch reviews by the target user
    final userReviews = await _getUserReviews(userId);

    // Fetch all reviews (needed to compare against other users)
    final allReviews = await _getAllReviews();

    // Compute similarity scores between this user and all others
    final similarityScores = _calculateSimilarity(userId, userReviews, allReviews);

    // Pick top 5 most similar users (excluding self)
    final topTwins = similarityScores.entries
        .where((e) => e.key != userId)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final twinIds = topTwins.take(5).map((e) => e.key).toList();

    // Get meals those top twins rated highly
    final recommendedMeals = await _getHighlyRatedMealsByUsers(twinIds);

    // Exclude meals the user has already reviewed
    final reviewedMealNames = userReviews.map((r) => r.meal).toSet();
    final unseenMeals = recommendedMeals
        .where((meal) => !reviewedMealNames.contains(meal.name))
        .toList();

    return unseenMeals;
  }

  /// Fetches all reviews written by a specific user
  Future<List<Review>> _getUserReviews(String userId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  /// Fetches all reviews in the system
  Future<List<Review>> _getAllReviews() async {
    final snapshot = await _firestore.collection('reviews').get();
    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  /// Calculates cosine similarity between the target user
  /// and all other users based on overlapping meal ratings.
  Map<String, double> _calculateSimilarity(
    String targetUserId,
    List<Review> targetReviews,
    List<Review> allReviews,
  ) {
    // Map of target user's ratings by meal name
    final targetMap = {for (var r in targetReviews) r.meal: r.rating.toDouble()};

    // Group all reviews by userId
    final userGroups = <String, List<Review>>{};
    for (var r in allReviews) {
      userGroups.putIfAbsent(r.userId, () => []).add(r);
    }

    final scores = <String, double>{};
    for (var entry in userGroups.entries) {
      if (entry.key == targetUserId) continue;

      // Map of another user's ratings
      final otherMap = {for (var r in entry.value) r.meal: r.rating.toDouble()};

      // Find meals both users have rated
      final commonMeals = targetMap.keys.toSet().intersection(otherMap.keys.toSet());
      if (commonMeals.isEmpty) continue;

      // Compute cosine similarity
      final dotProduct = commonMeals
          .map((id) => targetMap[id]! * otherMap[id]!)
          .reduce((a, b) => a + b);
      final targetMagnitude = _magnitude(targetMap, commonMeals);
      final otherMagnitude = _magnitude(otherMap, commonMeals);

      final similarity = dotProduct / (targetMagnitude * otherMagnitude);
      scores[entry.key] = similarity;
    }

    return scores;
  }

  /// Helper to compute vector magnitude for cosine similarity
  double _magnitude(Map<String, double> ratings, Set<String> keys) {
    final sumSquares = keys.map((id) => pow(ratings[id]!, 2)).reduce((a, b) => a + b);
    return sqrt(sumSquares);
  }

  /// Fetches up to 3 distinct meals that top twins rated highly
  /// and that are also present on today's menu.
  Future<List<Meal>> _getHighlyRatedMealsByUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Get high-rated reviews from top twins
    final snapshot = await _firestore
        .collection('reviews')
        .where('userId', whereIn: userIds.take(10).toList()) // Firestore limit
        .where('rating', isGreaterThan: 4)
        .get();

    // Collect distinct meal names from those reviews
    final mealNames = snapshot.docs
        .map((doc) => (doc['meal'] as String).trim().toLowerCase())
        .toSet();
    if (mealNames.isEmpty) return [];

    // Fetch today's meals
    final today = DateTime.now();
    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final mealSnapshot = await _firestore
        .collection('meals')
        .doc(todayKey)
        .collection('meals')
        .get();
    final todaysMeals = mealSnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();

    // Match twin-recommended meals against today's menu
    final matchedMeals = todaysMeals
        .where((m) => mealNames.contains(m.name.trim().toLowerCase()))
        .toList();

    // Deduplicate by meal name and limit to 3
    final uniqueMeals = {for (var m in matchedMeals) m.name: m}.values.toList();
    return uniqueMeals.take(3).toList();
  }
}