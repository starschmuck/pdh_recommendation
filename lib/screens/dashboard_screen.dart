import 'package:flutter/material.dart';
import 'package:pdh_recommendation/models/meal.dart';
import 'package:pdh_recommendation/services/crowd_rating_service.dart';
import 'package:pdh_recommendation/services/favorites_service.dart';
import 'package:pdh_recommendation/services/tasteful_twin_service.dart';

import 'package:pdh_recommendation/widgets/dashboard_crowd_card.dart';
import 'package:pdh_recommendation/widgets/dashboard_favorites_card.dart';
import 'package:pdh_recommendation/widgets/dashboard_popularity_card.dart';
import 'package:pdh_recommendation/widgets/dashboard_prediction_card.dart';
import 'package:pdh_recommendation/widgets/dashboard_realized_card.dart';
import 'package:pdh_recommendation/widgets/dashboard_suggestion_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Meal>> _twinSuggestions;
  late Future<List<Meal>> _crowdFavorites;
  late Future<List<Meal>> _favorites;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? ""; 
    _twinSuggestions = TastefulTwinService().getRecommendationsForUser(userId);
    _crowdFavorites = CrowdRatingService().getTopRatedMealsForToday();
    _favorites = FavoritesService().getTodaysFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Recommendations Section ---
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "What’s Tasty Today?",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),

                      FutureBuilder<List<Meal>>(
                        future: _twinSuggestions,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return DashboardSuggestionCard(suggestions: []); // fallback inside card
                          }
                          final meals = snapshot.data ?? [];
                          return DashboardSuggestionCard(
                            suggestions: meals.map((m) => m.name).toList(),
                          );
                        },
                      ),

                      FutureBuilder<List<Meal>>(
                        future: _crowdFavorites,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const DashboardCrowdCard(crowdFavorites: []);
                          }
                          final meals = snapshot.data ?? [];
                          return DashboardCrowdCard(
                            crowdFavorites: meals.map((m) => m.name).toList(),
                          );
                        },
                      ),

                      FutureBuilder<List<Meal>>(
                        future: _favorites,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const DashboardFavoritesCard(favorites: []);
                          }
                          if (snapshot.hasError) {
                            return const DashboardFavoritesCard(favorites: []);
                          }
                          final meals = snapshot.data ?? [];
                          return DashboardFavoritesCard(
                            favorites: meals.map((m) => m.name).toList(),
                          );
                        },
                      ),

                      DashboardRealizedCard(realizedSuggestions: []),
                    ],
                  ),
                ),
              ),

              // --- Rankings Section ---
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How am I ranked?",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DashboardPredictionsCard(
                        placement: "You’re 123 out of 4,234",
                        accuracy: "99% accuracy",
                      ),
                      DashboardPopularityCard(
                        placement: "You’re 456 out of 4,324",
                        likeSummary: "49 total review likes",
                      ),
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
}