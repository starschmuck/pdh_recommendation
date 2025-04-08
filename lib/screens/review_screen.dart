import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdh_recommendation/screens/camera_screen.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../widgets/review_card.dart';
import '../widgets/suggestion_card.dart';
import '../widgets/action_button.dart';

final imagePicker = ImagePicker();

typedef FoodEntry = DropdownMenuEntry<Food>;

enum Food {
  pizza('Pizza'),
  pasta('Pasta'),
  salad('Salad'),
  sandwich('Sandwich'),
  burger('Burger'),
  sushi('Sushi');

  const Food(this.label);
  final String label;

  static final List<FoodEntry> entries = UnmodifiableListView<FoodEntry>(
    Food.values
        .map<FoodEntry>(
          (Food food) =>
              DropdownMenuEntry<Food>(value: food, label: food.label),
        )
        .toList(),
  );
}

/// Returns the current meal period based on the time.
/// Breakfast: 7:30-10:30 AM, Lunch: 10:30-4:30 PM, Dinner: 4:30-9:30 PM.
/// Outside of these hours returns null (hall closed).
String? getCurrentMealPeriod() {
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  final breakfastStart = 7 * 60 + 30;
  final breakfastEnd = 10 * 60 + 30;
  final lunchStart = breakfastEnd;
  final lunchEnd = 16 * 60 + 30;
  final dinnerStart = lunchEnd;
  final dinnerEnd = 21 * 60 + 30;

  if (currentMinutes >= breakfastStart && currentMinutes < breakfastEnd) {
    return 'breakfast';
  } else if (currentMinutes >= lunchStart && currentMinutes < lunchEnd) {
    return 'lunch';
  } else if (currentMinutes >= dinnerStart && currentMinutes < dinnerEnd) {
    return 'dinner';
  } else {
    return null; // Dining hall closed
  }
}

/// Capitalizes the first letter of the given string.
String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  XFile? image;
  XFile? photo;
  double sliderValue = .5;

  // Define the available tags.
  final List<String> availableTags = [
    'Healthy',
    'Flavorful',
    'Spicy',
    'Sweet',
    'Energy',
    'Focus',
    'Filling',
    'Comforting',
    'Refreshing',
  ];
  // List of tags the user has selected.
  List<String> selectedTags = [];

  // Holds the selected meal (retrieved from Firestore).
  String? selectedMeal;

  // Controller for review text.
  final TextEditingController reviewTextController = TextEditingController();

  /// Stub for image upload.
  /// Replace with Firebase Storage integration as needed.
  Future<String?> uploadImage(File file) async {
    // Upload file to storage and return its URL.
    return file.path; // Placeholder, returns local path.
  }

  /// Submits the review to Firestore.
  Future<void> submitReview() async {
    // Check current meal period.
    final currentMealPeriod = getCurrentMealPeriod();
    if (currentMealPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Panther Dining Hall is closed now.")),
      );
      return;
    }
    // Validate required fields.
    if (selectedMeal == null ||
        sliderValue == 0 ||
        selectedTags.isEmpty ||
        reviewTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    String? imageUrl;
    // Optionally upload the selected image (if any).
    if (image != null) {
      imageUrl = await uploadImage(File(image!.path));
    } else if (photo != null) {
      imageUrl = await uploadImage(File(photo!.path));
    }

    // Construct review object.
    final reviewData = {
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'meal': selectedMeal,
      'rating': sliderValue,
      'tags': selectedTags,
      'reviewText': reviewTextController.text.trim(),
      'imageUrl': imageUrl, // May be null if no image selected.
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Submit the review to Firestore.
    try {
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Review submitted!")));
      // Optionally clear the form here.
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access the app state.
    final appState = Provider.of<MyAppState>(context);
    final currentMealPeriod = getCurrentMealPeriod();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body:
          appState.isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Leave a Review!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Food Selection: Either a dropdown if open, or a closed message.
                              currentMealPeriod == null
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Panther Dining Hall is closed",
                                      ),
                                    ),
                                  )
                                  : FutureBuilder<QuerySnapshot>(
                                    future:
                                        FirebaseFirestore.instance
                                            .collection('meals')
                                            .where(
                                              'meal_type',
                                              isEqualTo: capitalize(
                                                currentMealPeriod,
                                              ),
                                            )
                                            .get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      // Extract meal names (or IDs) from documents.
                                      final meals = snapshot.data!.docs;
                                      return DropdownButton<String>(
                                        hint: Text("Select a meal"),
                                        value: selectedMeal,
                                        items:
                                            meals.map((doc) {
                                              final mealName =
                                                  doc['name'] as String;
                                              return DropdownMenuItem<String>(
                                                value: mealName,
                                                child: Text(mealName),
                                              );
                                            }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedMeal = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                              // Star Rating Section
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    IconData iconData;
                                    Color color;

                                    if (sliderValue >= index + 1) {
                                      iconData = Icons.star;
                                      color = Colors.amber;
                                    } else if (sliderValue >= index + 0.5) {
                                      iconData = Icons.star_half;
                                      color = Colors.amber;
                                    } else {
                                      iconData = Icons.star_border;
                                      color = Colors.grey;
                                    }
                                    return Icon(
                                      iconData,
                                      color: color,
                                      size: 32,
                                    );
                                  }),
                                ),
                              ),
                              Slider(
                                max: 5,
                                divisions: 10,
                                value: sliderValue,
                                onChanged: (double value) {
                                  setState(() {
                                    sliderValue = value;
                                  });
                                },
                              ),
                              Center(
                                child: Text(
                                  'Rating: $sliderValue Stars',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Horizontal Tag Selection System
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: SizedBox(
                                  height: 40.0,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        availableTags.map((tag) {
                                          bool isSelected = selectedTags
                                              .contains(tag);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0,
                                            ),
                                            child: ChoiceChip(
                                              label: Text(tag),
                                              selected: isSelected,
                                              onSelected: (selected) {
                                                setState(() {
                                                  if (selected) {
                                                    selectedTags.add(tag);
                                                  } else {
                                                    selectedTags.remove(tag);
                                                  }
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              // Review Text Field with Controller
                              TextField(
                                controller: reviewTextController,
                                decoration: InputDecoration(
                                  hintText: "Write a review...",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              // Photo and Image Upload Controls
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                        ),
                                        child: Icon(Icons.camera_alt),
                                        onPressed: () async {
                                          final XFile? pickedPhoto =
                                              await imagePicker.pickImage(
                                                source: ImageSource.camera,
                                              );
                                          setState(() {
                                            photo = pickedPhoto;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                          ),
                                        ),
                                        child: Icon(Icons.image),
                                        onPressed: () async {
                                          final XFile? pickedImage =
                                              await imagePicker.pickImage(
                                                source: ImageSource.gallery,
                                              );
                                          setState(() {
                                            image = pickedImage;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Display Captured Photo/Image
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (photo != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text('Photo Taken:'),
                                          SizedBox(height: 8.0),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: 100,
                                              maxHeight: 100,
                                            ),
                                            child: Image.file(
                                              File(photo!.path),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (image != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text('Image Selected:'),
                                          SizedBox(height: 8.0),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: 100,
                                              maxHeight: 100,
                                            ),
                                            child: Image.file(
                                              File(image!.path),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Submit Button
                      ElevatedButton(
                        onPressed: submitReview,
                        child: Text("Submit Review"),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
