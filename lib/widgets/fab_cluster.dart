import 'package:flutter/material.dart';
import 'package:pdh_recommendation/screens/review_screen.dart';
import 'package:pdh_recommendation/screens/suggestion_screen.dart';
import 'package:pdh_recommendation/screens/prediction_screen.dart';

class FabCluster extends StatefulWidget {
  const FabCluster({super.key});

  @override
  State<FabCluster> createState() => _FabClusterState();
}

class _FabClusterState extends State<FabCluster> {
  bool _isFabExpanded = false;
  void _toggleFab() => setState(() => _isFabExpanded = !_isFabExpanded);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Review
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
            right: 16,
          bottom: _isFabExpanded ? 200 : 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1 : 0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'fab_review',
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.rate_review),
                label: const Text('Review'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReviewPage()),
                  );
                  _toggleFab();
                },
              ),
            ),
          ),
        ),
        // Suggest
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16,
          bottom: _isFabExpanded ? 140 : 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1 : 0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'fab_suggest',
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.edit),
                label: const Text('Suggest'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SuggestionPage()),
                  );
                  _toggleFab();
                },
              ),
            ),
          ),
        ),
        // Predict
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16,
          bottom: _isFabExpanded ? 80 : 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1 : 0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'fab_predict',
                backgroundColor: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.help_outline),
                label: const Text('Guess'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PredictionScreen()),
                  );
                  _toggleFab();
                },
              ),
            ),
          ),
        ),
        // Toggle
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'fab_toggle',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: _toggleFab,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}