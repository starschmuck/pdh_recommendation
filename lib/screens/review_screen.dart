import 'dart:io';

import 'package:pdh_recommendation/models/review.dart';
import 'package:pdh_recommendation/repositories/review_repository';
import 'package:video_player/video_player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../main.dart';

final imagePicker = ImagePicker();

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
  XFile? selectedImage;
  XFile? selectedVideo;
  double sliderValue = 0.0;
  bool _submitting = false;
  bool isFavorite = false;
  List<String> userFavorites = [];
  List<QueryDocumentSnapshot> _meals = [];
  bool _mealsLoading = true;
  String? _mealsError;
  VideoPlayerController? _videoController;

  Future<void> pickImage(ImageSource source) async {
    if (_submitting) return;

    try {
      final picked = await imagePicker.pickImage(source: source);
      if (picked != null) {
        setState(() => selectedImage = picked);
      }
    } catch (e) {
      print("❌ pickImage error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    if (_submitting) return;

    try {
      final picked = await imagePicker.pickVideo(
        source: source,
        maxDuration: Duration(seconds: 10), // limit duration
        preferredCameraDevice: CameraDevice.rear, // choose camera
      );

      if (picked == null) return;

      print("▶️ Video picked: ${picked.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Compressing video…")),
      );

      // Compress the video using video_compress
      final info = await VideoCompress.compressVideo(
        picked.path,
        quality: VideoQuality.LowQuality, // low resolution
        deleteOrigin: true, // trash original
        includeAudio: false, // no audio
      );

      if (info == null || info.path == null) {
        throw Exception("Video compression failed");
      }

      setState(() {
        selectedVideo = XFile(info.path!); // update state with compressed file
      });

      final file = XFile(info.path!);
      
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          setState (() {
            selectedVideo = file;
          }); 
          // refresh UI
          _videoController!.setLooping(true); // auto loop
          _videoController!.play(); // auto play
          
        });
      

      print("✅ Video compressed: ${info.path}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video compressed successfully!")),
      );

    } catch (e) {
      print("❌ pickVideo error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error picking video: $e")));
    }
  }


  List<String> filterMeals(List<String> meals, String range) {
    switch (range) {
      case 'favorite':
      return userFavorites;

      case 'A-H':
        return meals.where((m) => m[0].toUpperCase().compareTo('A') >= 0 && m[0].toUpperCase().compareTo('H') <= 0).toList();
      case 'I-P':
        return meals.where((m) => m[0].toUpperCase().compareTo('I') >= 0 && m[0].toUpperCase().compareTo('P') <= 0).toList();
      case 'Q-Z':
        return meals.where((m) => m[0].toUpperCase().compareTo('Q') >= 0 && m[0].toUpperCase().compareTo('Z') <= 0).toList();
      default:
        return meals;

    }
  }

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
          _loadMeals();
          _loadFavorites();
        })
        .catchError((e) {
          print('❌ Firebase.initializeApp error: $e');
        });
  }

  Future<void> _loadMeals() async {
  final currentMealPeriod = getCurrentMealPeriod();
  if (currentMealPeriod == null) return; // hall closed, skip

  final todayDate = getTodayDateString();
  final mealsCollectionRef = FirebaseFirestore.instance
      .collection('meals')
      .doc(todayDate)
      .collection('meals');
  final filterMealType = capitalize(currentMealPeriod);

  try {
    final snap = await mealsCollectionRef
        .where('meal_type', isEqualTo: filterMealType)
        .get();

    setState(() {
      _meals = snap.docs..sort((a, b) {
        final nameA = (a.data())['name'] ?? a.id;
        final nameB = (b.data())['name'] ?? b.id;
        return (nameA as String).compareTo(nameB as String);
      });
      _mealsLoading = false;
    });
  } catch (e) {
    setState(() {
      _mealsError = e.toString();
      _mealsLoading = false;
    });
  }
}

  void _showMealOptions(String range, List<QueryDocumentSnapshot> allMeals) {
    final mealNames = allMeals
        .map((doc) => (doc.data() as Map<String, dynamic>)['name'] as String? ?? doc.id)
        .toList();
    
    final filtered = filterMeals(mealNames, range);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (_, index) {
            final meal = filtered[index];
            return ListTile(
              title: Text(meal),
              onTap: () {
                setState(() {
                  selectedMeal = meal;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _loadFavorites() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final data = doc.data();
  if (data != null && data['favorites'] is List) {
    setState(() {
      userFavorites = List<String>.from(data['favorites']);
    });
  } else {
    setState(() {
      userFavorites = [];
    });
  }
}

  Future<String?> uploadImage(File file, String reviewId) async {
    print("🛠️ uploadImage start for ${file.path}");
    // grab user id
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // if not logged in, throw exception
    if (uid == null) throw Exception("Not logged in");

    try {
      // name image file as milliseconds since epoch
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      // store image at user 
      final storagePath =
          'users/$uid/$reviewId/images/$fileName';

      // store to database
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

  Future<String?> uploadVideo(File file, String reviewId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("Not logged in");

    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.mp4";
      final storagePath = 'users/$uid/$reviewId/videos/$fileName';
      final ref = FirebaseStorage.instance.ref(storagePath);
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("❌ uploadVideo error: $e");
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

    // ✅ Validation
    if (selectedMeal == null ||
        sliderValue <= 0 ||
        reviewTextController.text.trim().isEmpty) {
      print(
        "⚠️ Validation failed: "
        "meal=$selectedMeal, rating=$sliderValue, "
        "textLength=${reviewTextController.text.trim().length}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    setState(() => _submitting = true);

    final reviewRef = FirebaseFirestore.instance.collection('reviews').doc(); // create doc reference
    final reviewId = reviewRef.id;

    String? mediaUrl;
    try {
      if (selectedImage != null) {
        print("▶️ Starting image upload: ${selectedImage!.path}");
        mediaUrl = await uploadImage(File(selectedImage!.path), reviewId);
        print("✅ uploadImage returned URL: $mediaUrl");

        if (mediaUrl == null) {
          throw Exception("Image upload failed");
        }
      } else if (selectedVideo != null) {
        mediaUrl = await uploadVideo(File(selectedVideo!.path), reviewId);
      }
    } catch (e) {
      print("❌ uploadImage threw error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
      setState(() => _submitting = false);
      return;
    }

    // after you compute mediaUrl and have reviewId
    final repo = ReviewRepository();
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      throw Exception('Not logged in');
    }

    // Build Review model (ensure timestamp uses DateTime.now(); repo will write serverTimestamp on create)
    final review = Review(
      id: reviewId,
      userId: currentUid,
      meal: selectedMeal ?? '',
      rating: sliderValue,
      reviewText: reviewTextController.text.trim(),
      timestamp: DateTime.now(),
      tags: selectedTags,
      mediaUrl: mediaUrl,
      likesCount: 0, // always default 0 on creation
    );


    try {
      await repo.createReview(review);

      // ✅ Update favorites only if the heart toggle is on
      if (selectedMeal != null && userFavorites.contains(selectedMeal)) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
          await userDoc.set({
            'favorites': FieldValue.arrayUnion([selectedMeal])
          }, SetOptions(merge: true));
          print("✅ Updated favorites with $selectedMeal");
        }
      }

      // ✅ When review is complete, return to previous screen
      final appState = Provider.of<MyAppState>(context, listen: false);
      appState.setSelectedIndex(2); // Dashboard tab index
      Navigator.of(context).pop();  // close the review screen

      // ✅ Reset UI state
      setState(() {
        selectedImage = null;        
        sliderValue = .5;
        selectedTags.clear();
        reviewTextController.clear();
        selectedMeal = null;
      });
    } catch (e) {
      print("❌ Firestore.add error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting review: $e")),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

void showCameraOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext ctx) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.camera_alt),
            label: Text("Take Photo"),
            onPressed: () {
              Navigator.pop(ctx);
              pickImage(ImageSource.camera);
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.videocam),
            label: Text("Record Video"),
            onPressed: () {
              Navigator.pop(ctx);
              pickVideo(ImageSource.camera);
            },
          ),
        ],
      );
    },
  );
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
      backgroundColor: Colors.white,
      body:
          appState.isLoading // If Loading...
              ? Center(child: CircularProgressIndicator(color: Colors.white)) // Show circular loading indicator
              : SafeArea( // after loading, create the rest of the visuals
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(  // column that represents all the content on the page
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card( // card in the main column which carries all the info
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(  // column within the card that holds all actual stuff on the card
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text( // header text to remind individuals to leave reviews
                                "Leave a Review!",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              if (currentMealPeriod == null)  // if the dining hall is closed, shut down reviews.
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text("Dining Hall closed"),  
                                  ),
                                )
                              else
                              if (_mealsLoading)
                                Center(child: CircularProgressIndicator())
                              else if (_mealsError != null)
                                Center(child: Text("Error loading meals: $_mealsError"))
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (selectedMeal != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          selectedMeal!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => _showMealOptions('favorite', _meals),
                                          child: Icon(Icons.favorite, color: Colors.red),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _showMealOptions('A-H', _meals),
                                          child: Text('A-H'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _showMealOptions('I-P', _meals),
                                          child: Text('I-P'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _showMealOptions('Q-Z', _meals),
                                          child: Text('Q-Z'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),


                              SizedBox(height: 16),
                              Row(  // row with star icons and favorite button
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    ...List.generate(5, (i) {
                                    final icon =
                                        sliderValue >= i + 1
                                            ? Icons.star
                                            : sliderValue >= i + 0.5
                                            ? Icons.star_half
                                            : Icons.star_border;
                                    return Icon(icon, size: 32);
                                  }),
                                  SizedBox(width: 12), // space between stars and heart
                                  GestureDetector(
                                    onTap: () {
                                      if (selectedMeal == null) return; // can't favorite without a meal selected
                                      setState(() {
                                        if (userFavorites.contains(selectedMeal)) {
                                          // Toggle off locally
                                          userFavorites.remove(selectedMeal);
                                        } else {
                                          // Toggle on locally
                                          userFavorites.add(selectedMeal!);
                                        }
                                      });
                                    },
                                    child: Icon(
                                      selectedMeal != null && userFavorites.contains(selectedMeal)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: selectedMeal != null && userFavorites.contains(selectedMeal)
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 32,
                                    ),
                                  )

                                ]
                              ),
                              Slider( // slider to allow user to enter star rating
                                max: 5,
                                divisions: 10,
                                value: sliderValue,
                                onChanged:
                                    _submitting
                                        ? null
                                        : (v) =>
                                            setState(() => sliderValue = v),
                              ),
                              Center( // text displaying star rating value to user
                                child: Text(
                                  'Rating: $sliderValue Stars',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              SizedBox(height: 16),
                              SizedBox( // horizontal scroll for tag selection
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
                              TextField(  // review text field for review content
                                controller: reviewTextController,
                                decoration: InputDecoration(
                                  hintText: "Write a review…",
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                enabled: !_submitting,
                              ),

                              SizedBox(height: 8),
                              Row(  // buttons for picking images or videos
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => showCameraOptions(context),
                                      child: Icon(Icons.camera_alt),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => pickImage(ImageSource.gallery),
                                      child: Icon(Icons.image),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 8),

                              Row(  // row containing photo if photo was taken
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (selectedImage != null)
                                    Column(
                                      children: [
                                        Text('Selected Image'),
                                        SizedBox(height: 8),
                                        Image.file(
                                          File(selectedImage!.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),

                                  if (selectedVideo != null && _videoController != null && _videoController!.value.isInitialized)
                                    Column(
                                      children: [
                                        Text('Selected Video'),
                                        SizedBox(height: 8),
                                        Container(
                                          width: 100,
                                          height: 100,
                                          child: AspectRatio(
                                            aspectRatio: _videoController!.value.aspectRatio,
                                            child: VideoPlayer(_videoController!),
                                            )
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _videoController!.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _videoController!.value.isPlaying
                                                ? _videoController!.pause()
                                                : _videoController!.play();
                                            });
                                          },
                                        )
                                      ],
                                    )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 16),
                      ElevatedButton( // button to submit review when finished
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
      floatingActionButton: FloatingActionButton( // button to allow user to return to previous screen
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
