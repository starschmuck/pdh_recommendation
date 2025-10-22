import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/meal.dart';

class FavoritesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns up to 3 favorite meals that are also on today's menu
  Future<List<Meal>> getTodaysFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Get user favorites (stored as meal names)
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};
    final favorites = (userData['favorites'] as List<dynamic>?)
            ?.map((e) => e.toString().trim().toLowerCase())
            .toList() ??
        [];

    if (favorites.isEmpty) return [];

    // Get today's meals from /meals/{todayKey}/meals
    final todayKey = _todayKey();
    final mealSnapshot = await _firestore
        .collection('meals')
        .doc(todayKey)
        .collection('meals')
        .get();

    final todaysMeals = mealSnapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList();

    // Match favorites against today's meals by normalized name
    final matchedMeals = todaysMeals
        .where((meal) => favorites.contains(meal.name.trim().toLowerCase()))
        .toList();

    // Limit to 3 unique favorites
    final uniqueMeals = {
      for (var m in matchedMeals) m.name: m
    }.values.toList();

    return uniqueMeals.take(3).toList();
  }

  /// Helper to generate today’s menu doc ID
  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }
}