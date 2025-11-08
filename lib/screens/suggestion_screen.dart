import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdh_recommendation/models/suggestion.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final TextEditingController suggestionTitleController = TextEditingController();
  final TextEditingController suggestionTextController = TextEditingController();
  final TextEditingController recipeLinkController = TextEditingController(); // NEW

  @override
  void dispose() {
    suggestionTitleController.dispose();
    suggestionTextController.dispose();
    recipeLinkController.dispose(); // NEW
    super.dispose();
  }

  bool _looksLikeUrl(String v) {
    final t = v.toLowerCase().trim();
    return t.startsWith('http://') || t.startsWith('https://');
  }

  Future<void> submitSuggestion() async {
    final title = suggestionTitleController.text.trim();
    final suggestionText = suggestionTextController.text.trim();
    final recipeLinkRaw = recipeLinkController.text.trim();

    if (title.isEmpty || suggestionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both the title and suggestion details.")),
      );
      return;
    }

    if (recipeLinkRaw.isNotEmpty && !_looksLikeUrl(recipeLinkRaw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe link must start with http(s)://")),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance.collection('suggestions').doc();

    final suggestion = Suggestion(
      suggestionId: docRef.id,
      userId: userId,
      title: title,
      suggestionText: suggestionText,
      timestamp: DateTime.now(), // will be replaced with serverTimestamp below
      recipeLink: recipeLinkRaw.isEmpty ? null : recipeLinkRaw,
    );

    final data = suggestion.toMap();
    // Preserve existing server-side timestamp behavior
    data['timestamp'] = FieldValue.serverTimestamp();

    try {
      await docRef.set(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Suggestion submitted!")),
      );
      suggestionTitleController.clear();
      suggestionTextController.clear();
      recipeLinkController.clear(); // reset link
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Submit a Suggestion!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: suggestionTitleController,
                        decoration: const InputDecoration(
                          hintText: "Suggestion Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: suggestionTextController,
                        decoration: const InputDecoration(
                          hintText: "Enter your suggestion...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: recipeLinkController,
                        decoration: const InputDecoration(
                          hintText: "Recipe link (optional, starts with http:// or https://)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitSuggestion,
                child: const Text("Submit Suggestion"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary, // match Review
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}