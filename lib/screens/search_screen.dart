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

  List<Map<String, dynamic>> _allReviews = [];
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _fetchUsers();
    _fetchSuggestions();
  }

  void _fetchReviews() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('reviews').get();
      setState(() {
        _allReviews =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['name'] = data['meal'] ?? '';
              data['rating'] =
                  data['rating'] != null ? (data['rating'] as num).toInt() : 0;
              return data;
            }).toList();
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

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

  void _fetchSuggestions() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('suggestions').get();
      setState(() {
        _allSuggestions =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['name'] = data['title'] ?? '';
              data['rating'] =
                  data['rating'] != null ? (data['rating'] as num).toInt() : 0;
              return data;
            }).toList();
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

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
                SearchBarWidget(
                  onQueryChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SearchResultsSection(
                  title:
                      'Review Results for "${_searchQuery.isEmpty ? "" : _searchQuery}"',
                  items: _filteredReviews,
                ),
                const SizedBox(height: 12),
                SearchResultsSection(
                  title:
                      'Suggestion Results for "${_searchQuery.isEmpty ? "" : _searchQuery}"',
                  items: _filteredSuggestions,
                  hasNoResults: _filteredSuggestions.isEmpty,
                ),
                const SizedBox(height: 12),
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
