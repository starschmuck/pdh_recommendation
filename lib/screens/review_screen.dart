import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
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
        values.map<FoodEntry>(
          (Food food ) => FoodEntry(
            value: food,
            label: food.label,
          ),
        ),
      );
  }


class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
    
    XFile? image;
    XFile? photo;
    double sliderValue = .5;
    
  @override
  Widget build(BuildContext context) {
    // Access the app state
    final appState = Provider.of<MyAppState>(context);

    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: appState.isLoading
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
                              fontWeight: FontWeight.bold
                              )
                              
                            ),
                            DropdownMenu<Food>(
                              expandedInsets: EdgeInsets.zero,
                              dropdownMenuEntries: Food.entries,
                              //onSelected: (Food? food){
                                //setState(() {
                                //  selectedFood = food;
                                // });
                              //},
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  // Determine icon based on rating
                                  IconData iconData;
                                  Color color;
                              
                                  if(sliderValue >= index + 1){
                                    // Full Star
                                    iconData = Icons.star;
                                    color = Colors.amber;
                                  } else if (sliderValue >= index + .5) {
                                    // Half Star
                                    iconData = Icons.star_half;
                                    color = Colors.amber;
                                  }
                                  else {
                                    // Empty Star
                                    iconData = Icons.star_border;
                                    color = Colors.grey;
                                  }
                              
                                  return Icon(iconData, color: color, size: 32);
                              
                                }),
                              ),
                            ),
                            Slider(
                              max: 5,
                              divisions: 10,
                              //label: sliderValue.toString(),

                              value: sliderValue,
                              onChanged: (double value){
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
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Write a review...",
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),

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
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Icon(Icons.camera_alt),
                                      onPressed: () async {
                                        //final cameras = await availableCameras();
                                        // open camera_screen
                                        //Navigator.push(context, MaterialPageRoute(builder: (context) => TakePictureScreen(camera: cameras.first,)));
                                        final XFile? pickedPhto = await imagePicker.pickImage(source: ImageSource.camera);
                                        setState(() {
                                          photo = pickedPhto;
                                        });
                                      },
                                      )
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      child: Icon(Icons.image),
                                      onPressed: () async {
                                        final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                                        setState(() {
                                          image = pickedImage;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                                
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          child: Image.file(File(photo!.path))
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
                                          child: Image.file(File(image!.path))
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ]
                        )
                      )
                    )
                    
                  ],
                ),
              ),
            ),
      // Keep the refresh functionality from original code
      floatingActionButton: FloatingActionButton( 
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}