import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String name;
  final String mealType;
  final List<String> allergens;

  Meal({
    required this.id,
    required this.name,
    required this.mealType,
    required this.allergens,
  });

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      name: data['name'] ?? '',
      mealType: data['meal_type'] ?? '',
      allergens: (data['allergens'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'meal_type': mealType,
      'allergens': allergens,
    };
  }
}