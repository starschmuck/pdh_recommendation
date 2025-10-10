import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/review_results_card.dart';
import '../widgets/suggestion_results_card.dart';
import '../widgets/user_results_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  String _searchType = 'meal'; // default search type
  String _sortBy = 'time';     // default sort option

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Search bar ---
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) {
                  setState(() => _searchQuery = query);
                },
              ),

              const SizedBox(height: 12),

              // --- Search & Sort controls ---
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search by
                      Row(
                        children: [
                          const Text("Search by:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _searchType,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'meal', child: Text('Meal')),
                              DropdownMenuItem(
                                  value: 'tags', child: Text('Tags')),
                              DropdownMenuItem(
                                  value: 'rating', child: Text('Rating')),
                              DropdownMenuItem(
                                  value: 'text', child: Text('Text')),
                              DropdownMenuItem(
                                  value: 'users', child: Text('User')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _searchType = val;
                                  _sortBy = 'time'; // reset sort default
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      // Sort by
                      Row(
                        children: [
                          const Text("Sort by:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            items: _getSortOptionsForType(_searchType),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sortBy = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Results sections ---
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_searchType == 'meal' ||
                          _searchType == 'text' ||
                          _searchType == 'tags' ||
                          _searchType == 'rating')
                        _buildReviewResults(),

                      if (_searchType == 'meal' ||
                          _searchType == 'text' ||
                          _searchType == 'tags')
                        const SizedBox(height: 16),

                      if (_searchType == 'meal' ||
                          _searchType == 'text' ||
                          _searchType == 'tags')
                        _buildSuggestionResults(),

                      if (_searchType == 'users') const SizedBox(height: 16),

                      if (_searchType == 'users') _buildUserResults(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: sort options per type ---
  List<DropdownMenuItem<String>> _getSortOptionsForType(String type) {
    switch (type) {
      case 'meal':
      case 'text':
      case 'tags':
      case 'rating':
        return const [
          DropdownMenuItem(value: 'time', child: Text('Time')),
          DropdownMenuItem(value: 'rating', child: Text('Rating')),
        ];
      case 'users':
        return const [
          DropdownMenuItem(value: 'name', child: Text('Name')),
        ];
      default:
        return const [];
    }
  }

  // --- Reviews ---
  Widget _buildReviewResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error loading reviews");
        }
        final docs = snapshot.data?.docs ?? [];

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final meal = (data['meal'] ?? '').toString().toLowerCase();
          final text = (data['reviewText'] ?? '').toString().toLowerCase();
          final tags =
              (data['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();
          final rating = (data['rating'] ?? '').toString();

          switch (_searchType) {
            case 'meal':
              return meal.contains(_searchQuery.toLowerCase());
            case 'text':
              return text.contains(_searchQuery.toLowerCase());
            case 'tags':
              return tags.contains(_searchQuery.toLowerCase());
            case 'rating':
              return rating == _searchQuery;
            default:
              return false;
          }
        }).toList();

        // --- Apply sorting ---
        filtered.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          switch (_sortBy) {
            case 'time':
              final tsA = dataA['timestamp'] as Timestamp?;
              final tsB = dataB['timestamp'] as Timestamp?;
              return (tsB?.toDate() ?? DateTime(0))
                  .compareTo(tsA?.toDate() ?? DateTime(0));
            case 'rating':
              final rA = (dataA['rating'] ?? 0).toDouble();
              final rB = (dataB['rating'] ?? 0).toDouble();
              return rB.compareTo(rA);
            default:
              return 0;
          }
        });

        return ReviewResultsCard(
          reviewDocs: filtered,
          query: _searchQuery,
        );
      },
    );
  }

  // --- Suggestions ---
  Widget _buildSuggestionResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('suggestions').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error loading suggestions");
        }
        final docs = snapshot.data?.docs ?? [];

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = (data['title'] ?? '').toString().toLowerCase();
          final text = (data['suggestionText'] ?? '').toString().toLowerCase();
          final tags =
              (data['tags'] as List<dynamic>? ?? []).join(' ').toLowerCase();

          switch (_searchType) {
            case 'meal':
              return title.contains(_searchQuery.toLowerCase());
            case 'text':
              return text.contains(_searchQuery.toLowerCase());
            case 'tags':
              return tags.contains(_searchQuery.toLowerCase());
            default:
              return false;
          }
        }).toList();

        // --- Apply sorting ---
        filtered.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final tsA = dataA['timestamp'] as Timestamp?;
          final tsB = dataB['timestamp'] as Timestamp?;
          return (tsB?.toDate() ?? DateTime(0))
              .compareTo(tsA?.toDate() ?? DateTime(0));
        });

        return SuggestionResultsCard(
          suggestionDocs: filtered,
          query: _searchQuery,
        );
      },
    );
  }

  // --- Users ---
  Widget _buildUserResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error loading users");
        }
        final docs = snapshot.data?.docs ?? [];

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        // --- Apply sorting ---
        filtered.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          switch (_sortBy) {
            case 'name':
              final nA = (dataA['name'] ?? '').toString().toLowerCase();
              final nB = (dataB['name'] ?? '').toString().toLowerCase();
              return nA.compareTo(nB);
            default:
              return 0;
          }
        });

        return UserResultsCard(
          userDocs: filtered,
          query: _searchQuery,
        );
      },
    );
  }
}