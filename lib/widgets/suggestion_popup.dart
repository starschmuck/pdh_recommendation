import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showSuggestionPopup(BuildContext context, QueryDocumentSnapshot doc) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => SuggestionPopup(doc: doc),
  );
}

class SuggestionPopup extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const SuggestionPopup({Key? key, required this.doc}) : super(key: key);

  @override
  _SuggestionPopupState createState() => _SuggestionPopupState();
}

class _SuggestionPopupState extends State<SuggestionPopup> {
  String username = 'Anonymous';
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    final data = widget.doc.data() as Map<String, dynamic>;
    final String? userId = data['userId'];

    if (userId != null && userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((docSnapshot) {
            if (docSnapshot.exists) {
              final userData = docSnapshot.data() as Map<String, dynamic>;
              setState(() {
                username = userData['name'] ?? 'Anonymous';
                _isLoaded = true;
              });
            } else {
              setState(() => _isLoaded = true);
            }
          })
          .catchError((_) {
            setState(() => _isLoaded = true);
          });
    } else {
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final String meal = data['title'] ?? 'Unknown Meal';
    final String suggestionText =
        data['suggestionText'] ?? 'No suggestion provided.';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoaded
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meal,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By $username',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    SizedBox(height: 12),
                    Text(suggestionText),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                )
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
