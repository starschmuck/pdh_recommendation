import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal.dart';
import '../models/review.dart';

class MealRating {
  final String mealName;
  final double averageRating;

  MealRating({required this.mealName, required this.averageRating});
}

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

      // Deduplicate by meal name (keep the first occurrence)
      final Map<String, Meal> uniqueMeals = {};
      for (var m in meals) {
        uniqueMeals[m.name] = m;
      }
      final distinctMeals = uniqueMeals.values.toList();


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

      // Sort distinct meals by average rating
      distinctMeals.sort((a, b) {
        final ratingA = avgRatings[a.name] ?? 0;
        final ratingB = avgRatings[b.name] ?? 0;
        return ratingB.compareTo(ratingA);
      });


      // Return the top 3
      return distinctMeals.take(3).toList();

    } catch (e, st) {
      // In case of any error, log it and return empty list
      print("Error in getTopRatedMealsForToday: $e\n$st");
      return [];
    }
  }

  Future<List<Meal>> getAllRatedMealsForToday({int? limit}) async {
    try {
      final today = DateTime.now();
      final todayKey =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final mealsSnapshot = await _firestore
          .collection('meals')
          .doc(todayKey)
          .collection('meals')
          .get();

      if (mealsSnapshot.docs.isEmpty) return [];

      final meals = mealsSnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();

      // Deduplicate
      final Map<String, Meal> uniqueMeals = {};
      for (var m in meals) {
        uniqueMeals[m.name] = m;
      }
      final distinctMeals = uniqueMeals.values.toList();

      final mealNames = meals.map((m) => m.name).toSet();

      final reviewSnapshot = await _firestore.collection('reviews').get();
      if (reviewSnapshot.docs.isEmpty) return [];

      final reviews = reviewSnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .where((r) => mealNames.contains(r.meal))
          .toList();

      if (reviews.isEmpty) return [];

      // Aggregate ratings
      final Map<String, List<double>> ratingsByMeal = {};
      for (var r in reviews) {
        ratingsByMeal.putIfAbsent(r.meal, () => []).add(r.rating);
      }

      final avgRatings = {
        for (var entry in ratingsByMeal.entries)
          entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length
      };

      // Sort by average rating
      distinctMeals.sort((a, b) {
        final ratingA = avgRatings[a.name] ?? 0;
        final ratingB = avgRatings[b.name] ?? 0;
        return ratingB.compareTo(ratingA);
      });

      // Apply limit if provided
      return limit != null ? distinctMeals.take(limit).toList() : distinctMeals;
    } catch (e, st) {
      print("Error in getAllRatedMealsForToday: $e\n$st");
      return [];
    }
  }

  Future<List<MealRating>> getRatedMealsForToday({int? limit}) async {
    try {
      final today = DateTime.now();
      final todayKey =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      // Fetch today's meals
      final mealsSnapshot = await _firestore
          .collection('meals')
          .doc(todayKey)
          .collection('meals')
          .get();

      if (mealsSnapshot.docs.isEmpty) return [];

      final meals = mealsSnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();
      final mealNames = meals.map((m) => m.name).toSet();

      // Fetch reviews
      final reviewSnapshot = await _firestore.collection('reviews').get();
      if (reviewSnapshot.docs.isEmpty) return [];

      final reviews = reviewSnapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .where((r) => mealNames.contains(r.meal))
          .toList();

      if (reviews.isEmpty) return [];

      // Aggregate ratings
      final Map<String, List<double>> ratingsByMeal = {};
      for (var r in reviews) {
        ratingsByMeal.putIfAbsent(r.meal, () => []).add(r.rating);
      }

      // Compute averages
      final avgRatings = {
        for (var entry in ratingsByMeal.entries)
          entry.key: entry.value.reduce((a, b) => a + b) / entry.value.length
      };

      // Build MealRating list
      final ratedMeals = avgRatings.entries
          .map((e) => MealRating(mealName: e.key, averageRating: e.value))
          .toList();

      // Sort by rating
      ratedMeals.sort((a, b) => b.averageRating.compareTo(a.averageRating));

      // Apply limit if requested
      return limit != null ? ratedMeals.take(limit).toList() : ratedMeals;
    } catch (e, st) {
      print("Error in getRatedMealsForToday: $e\n$st");
      return [];
    }
  }
}