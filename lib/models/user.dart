import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final List<String> favoriteMealIds;

  User({
    required this.id,
    required this.favoriteMealIds,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      favoriteMealIds: List<String>.from(data['favoriteMealIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'favoriteMealIds': favoriteMealIds,
    };
  }
}