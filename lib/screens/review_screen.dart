import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

String? getCurrentMealPeriod() {
  final now = DateTime.now();
  final currentMinutes = now.hour * 60 + now.minute;
  const breakfastStart = 7 * 60 + 30;
  const breakfastEnd = 10 * 60 + 30;
  const lunchStart = breakfastEnd;
  const lunchEnd = 16 * 60 + 30;
  const dinnerStart = lunchEnd;
  const dinnerEnd = 23 * 60 + 30;

  if (currentMinutes >= breakfastStart && currentMinutes < breakfastEnd) {
    return 'breakfast';
  } else if (currentMinutes >= lunchStart && currentMinutes < lunchEnd) {
    return 'lunch';
  } else if (currentMinutes >= dinnerStart && currentMinutes < dinnerEnd) {
    return 'dinner';
  } else {
    return null;
  }
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String getTodayDateString() {
  final now = DateTime.now();
  return "${now.year.toString().padLeft(4, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.day.toString().padLeft(2, '0')}";
}

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  XFile? image;
  XFile? photo;
  double sliderValue = .5;
  bool _submitting = false;

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
  List<String> selectedTags = [];
  String? selectedMeal;
  final TextEditingController reviewTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure Firebase is initialized
    Firebase.initializeApp()
        .then((_) {
          print('✅ Firebase initialized');
        })
        .catchError((e) {
          print('❌ Firebase.initializeApp error: $e');
        });
  }

  Future<String?> uploadImage(File file) async {
    print("🛠️ uploadImage start for ${file.path}");
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
      final fileName = file.path.split('/').last;
      final storagePath =
          'reviews/$uid/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final ref = FirebaseStorage.instance.ref(storagePath);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen(
        (snap) {
          print(
            "⬆️ state=${snap.state} "
            "transferred=${snap.bytesTransferred}/${snap.totalBytes}",
          );
        },
        onError: (e) {
          print("⚠️ snapshotEvents error: $e");
        },
      );

      final snapshot = await uploadTask.timeout(
        Duration(seconds: 20),
        onTimeout: () {
          throw Exception("Upload timed out");
        },
      );
      print("✅ uploadTask completed: ${snapshot.state}");
      final url = await snapshot.ref.getDownloadURL();
      print("🔗 downloadURL: $url");
      return url;
    } catch (e, st) {
      print("❌ uploadImage error: $e\n$st");
      return null;
    }
  }

  Future<void> submitReview() async {
    print("🔔 submitReview called");
    final currentMealPeriod = getCurrentMealPeriod();
    if (currentMealPeriod == null) {
      print("⚠️ Hall closed, aborting submitReview");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Panther Dining Hall is closed now.")),
      );
      return;
    }

    if (selectedMeal == null ||
        sliderValue == 0 ||
        selectedTags.isEmpty ||
        reviewTextController.text.trim().isEmpty) {
      print(
        "⚠️ Validation failed: "
        "meal=$selectedMeal, rating=$sliderValue, "
        "tags=${selectedTags.length}, textLength=${reviewTextController.text.trim().length}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    setState(() => _submitting = true);

    String? imageUrl;
    try {
      print("▶️ Starting image upload: image=$image, photo=$photo");
      if (image != null) {
        imageUrl = await uploadImage(File(image!.path));
      } else if (photo != null) {
        imageUrl = await uploadImage(File(photo!.path));
      }
      print("✅ uploadImage returned URL: $imageUrl");
      if ((image != null || photo != null) && imageUrl == null) {
        throw Exception("Image upload failed");
      }
    } catch (e) {
      print("❌ uploadImage threw error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
      setState(() => _submitting = false);
      return;
    }

    final reviewData = {
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'meal': selectedMeal,
      'rating': sliderValue,
      'tags': selectedTags,
      'reviewText': reviewTextController.text.trim(),
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
    print("▶️ Writing review to Firestore: $reviewData");

    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .add(reviewData)
          .timeout(Duration(seconds: 10));
      print("✅ Firestore.add succeeded");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Review submitted!")));
      setState(() {
        image = null;
        photo = null;
        sliderValue = .5;
        selectedTags.clear();
        reviewTextController.clear();
        selectedMeal = null;
      });
    } catch (e) {
      print("❌ Firestore.add error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error submitting review: $e")));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<MyAppState>(context);
    final currentMealPeriod = getCurrentMealPeriod();
    final todayDate = getTodayDateString();

    final mealsCollectionRef = FirebaseFirestore.instance
        .collection('meals')
        .doc(todayDate)
        .collection('meals');
    final filterMealType =
        currentMealPeriod != null ? capitalize(currentMealPeriod) : '';

    final queryFuture =
        mealsCollectionRef.where('meal_type', isEqualTo: filterMealType).get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body:
          appState.isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
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

                              if (currentMealPeriod == null)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text("Dining Hall closed"),
                                  ),
                                )
                              else
                                FutureBuilder<QuerySnapshot>(
                                  future: queryFuture,
                                  builder: (ctx, snap) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snap.hasError || !snap.hasData) {
                                      return Center(
                                        child: Text(
                                          "Error loading meals: ${snap.error ?? 'no data'}",
                                        ),
                                      );
                                    }
                                    final docs = snap.data!.docs;
                                    final sorted =
                                        docs.toList()..sort((a, b) {
                                          final dataA =
                                              a.data() as Map<String, dynamic>;
                                          final dataB =
                                              b.data() as Map<String, dynamic>;
                                          final nameA =
                                              (dataA['name'] as String?) ??
                                              a.id;
                                          final nameB =
                                              (dataB['name'] as String?) ??
                                              b.id;
                                          return nameA.compareTo(nameB);
                                        });

                                    return DropdownButton<String>(
                                      hint: Text("Select a meal"),
                                      value: selectedMeal,
                                      isExpanded: true,
                                      items:
                                          sorted.map((doc) {
                                            final data =
                                                doc.data()
                                                    as Map<String, dynamic>;
                                            final mealName =
                                                data['name'] as String? ??
                                                doc.id;
                                            return DropdownMenuItem<String>(
                                              value: mealName,
                                              child: Text(mealName),
                                            );
                                          }).toList(),
                                      onChanged:
                                          (val) => setState(
                                            () => selectedMeal = val,
                                          ),
                                    );
                                  },
                                ),

                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (i) {
                                  final icon =
                                      sliderValue >= i + 1
                                          ? Icons.star
                                          : sliderValue >= i + 0.5
                                          ? Icons.star_half
                                          : Icons.star_border;
                                  return Icon(icon, size: 32);
                                }),
                              ),
                              Slider(
                                max: 5,
                                divisions: 10,
                                value: sliderValue,
                                onChanged:
                                    _submitting
                                        ? null
                                        : (v) =>
                                            setState(() => sliderValue = v),
                              ),
                              Center(
                                child: Text(
                                  'Rating: $sliderValue Stars',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              SizedBox(height: 16),
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      availableTags.map((tag) {
                                        final sel = selectedTags.contains(tag);
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: ChoiceChip(
                                            label: Text(tag),
                                            selected: sel,
                                            onSelected:
                                                _submitting
                                                    ? null
                                                    : (s) => setState(
                                                      () =>
                                                          s
                                                              ? selectedTags
                                                                  .add(tag)
                                                              : selectedTags
                                                                  .remove(tag),
                                                    ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),

                              SizedBox(height: 16),
                              TextField(
                                controller: reviewTextController,
                                decoration: InputDecoration(
                                  hintText: "Write a review…",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                enabled: !_submitting,
                              ),

                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          _submitting
                                              ? null
                                              : () async {
                                                final p = await imagePicker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.camera,
                                                    );
                                                setState(() => photo = p);
                                              },
                                      child: Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed:
                                          _submitting
                                              ? null
                                              : () async {
                                                final i = await imagePicker
                                                    .pickImage(
                                                      source:
                                                          ImageSource.gallery,
                                                    );
                                                setState(() => image = i);
                                              },
                                      child: Icon(Icons.image),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (photo != null)
                                    Column(
                                      children: [
                                        Text('Photo Taken'),
                                        SizedBox(height: 8),
                                        Image.file(
                                          File(photo!.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  if (image != null)
                                    Column(
                                      children: [
                                        Text('Image Selected'),
                                        SizedBox(height: 8),
                                        Image.file(
                                          File(image!.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitting ? null : submitReview,
                        child:
                            _submitting
                                ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text("Submit Review"),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
