import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_results_section.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';

  // These lists will store the data fetched from Firestore.
  List<Map<String, dynamic>> _allReviews = [];
  List<Map<String, dynamic>> _allUsers = [];
  // Suggestions remain empty for now.
  final List<Map<String, dynamic>> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _fetchUsers();
  }

  // Fetch reviews from the 'reviews' collection.
  void _fetchReviews() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reviews').get();
      setState(() {
        // Map each document into a Map<String, dynamic>.
        // Use the 'meal' field as the review title.
        _allReviews =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['name'] = data['meal'] ?? ''; // Use meal field as title.
              // Convert rating (which is stored as a double) to an int.
              data['rating'] =
                  data['rating'] != null ? (data['rating'] as num).toInt() : 0;
              return data;
            }).toList();
      });
    } catch (e) {
      // You might want to handle the error more gracefully.
      print('Error fetching reviews: $e');
    }
  }

  // Fetch users from the 'users' collection.
  void _fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _allUsers =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['name'] = data['name'] ?? '';
              return data;
            }).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  // Filtering functions based on the current search query.
  // Since we override review['name'] with the meal field,
  // this will search reviews by meal.
  List<Map<String, dynamic>> get _filteredReviews =>
      _allReviews
          .where(
            (review) => review['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();

  List<Map<String, dynamic>> get _filteredUsers =>
      _allUsers
          .where(
            (user) => user['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();

  List<Map<String, dynamic>> get _filteredSuggestions =>
      _allSuggestions
          .where(
            (suggestion) => suggestion['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The SearchBarWidget now notifies when the query changes.
                SearchBarWidget(
                  onQueryChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Reviews section populated from Firestore.
                SearchResultsSection(
                  title:
                      'Review Results for "${_searchQuery.isEmpty ? "" : _searchQuery}"',
                  items: _filteredReviews,
                ),
                const SizedBox(height: 12),
                // Suggestions section (will be empty until data is added).
                SearchResultsSection(
                  title:
                      'Suggestion Results for "${_searchQuery.isEmpty ? "" : _searchQuery}"',
                  items: _filteredSuggestions,
                  hasNoResults: _filteredSuggestions.isEmpty,
                ),
                const SizedBox(height: 12),
                // Users section populated from Firestore, with stars suppressed.
                SearchResultsSection(
                  showStars: false,
                  title:
                      'User Results for "${_searchQuery.isEmpty ? "" : _searchQuery}"',
                  items: _filteredUsers,
                  hasNoResults: _filteredUsers.isEmpty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
