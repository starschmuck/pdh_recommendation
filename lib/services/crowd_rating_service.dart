import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../models/review.dart';

class CrowdRatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetches the top 3 highest‑rated meals for today's menu
  Future<List<Meal>> getTopRatedMealsForToday() async {
    try {
      // Build today's key in format YYYY-MM-DD
      final today = DateTime.now();
      final todayKey =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Query today's meals from Firestore: /meals/{todayKey}/meals
      final mealsSnapshot = await _firestore
          .collection('meals')
          .doc(todayKey)
          .collection('meals')
          .get();

      // If no meals exist for today, return empty list
      if (mealsSnapshot.docs.isEmpty) return [];

      // Convert Firestore docs into Meal objects
      final meals = mealsSnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();

      // Collect the set of meal names for today's menu
      final mealNames = meals.map((m) => m.name).toSet();

      // Fetch all reviews from Firestore
      final reviewSnapshot = await _firestore.collection('reviews').get();

      // If no reviews exist at all, return empty list
      if (reviewSnapshot.docs.isEmpty) return [];

      // Convert Firestore docs into Review objects and filter
      // to only include reviews for today's meals
      final reviews = reviewSnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .where((r) => mealNames.contains(r.meal))
          .toList();

      // If no reviews match today's meals, return empty list
      if (reviews.isEmpty) return [];

      // Aggregate ratings by meal name
      final Map<String, List<double>> ratingsByMeal = {};
      for (var r in reviews) {
        ratingsByMeal.putIfAbsent(r.meal, () => []).add(r.rating);
      }

      // Compute average rating per meal
      final avgRatings = {
        for (var entry in ratingsByMeal.entries)
          entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length
      };

      // Sort today's meals by average rating (descending)
      meals.sort((a, b) {
        final ratingA = avgRatings[a.name] ?? 0;
        final ratingB = avgRatings[b.name] ?? 0;
        return ratingB.compareTo(ratingA);
      });

      // Return the top 3 meals
      return meals.take(3).toList();
    } catch (e, st) {
      // In case of any error, log it and return empty list
      print("Error in getTopRatedMealsForToday: $e\n$st");
      return [];
    }
  }
}