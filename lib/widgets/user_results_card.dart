import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserResultsCard extends StatelessWidget {
  final List<DocumentSnapshot> userDocs;
  final String query;

  const UserResultsCard({
    Key? key,
    required this.userDocs,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section header ---
            Text(
              query.isEmpty
                  ? "All Users"
                  : 'User Results for "$query"',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 8),

            // --- Results list ---
            if (userDocs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "No users found.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userDocs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final doc = userDocs[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final name = data['name'] ?? 'Anonymous';
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(name),
                    subtitle: Text(doc.id), // could be email/uid later
                    onTap: () {
                      // TODO: maybe navigate to user profile page
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}