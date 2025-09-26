import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  // Controllers for suggestion title and details.
  final TextEditingController suggestionTitleController =
      TextEditingController();
  final TextEditingController suggestionTextController =
      TextEditingController();

  @override
  void dispose() {
    suggestionTitleController.dispose();
    suggestionTextController.dispose();
    super.dispose();
  }

  /// Submits the suggestion.
  Future<void> submitSuggestion() async {
    final title = suggestionTitleController.text.trim();
    final suggestionText = suggestionTextController.text.trim();

    if (title.isEmpty || suggestionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill in both the title and suggestion details.",
          ),
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }

    // Create a document reference with an auto-generated ID.
    final docRef = FirebaseFirestore.instance.collection('suggestions').doc();

    final suggestionData = {
      'suggestionId': docRef.id,
      'userId': userId,
      'title': title,
      'suggestionText': suggestionText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await docRef.set(suggestionData);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Suggestion submitted!")));
      // Optionally clear the fields after submission.
      suggestionTitleController.clear();
      suggestionTextController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
