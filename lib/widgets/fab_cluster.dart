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
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 200.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'review',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReviewPage()),
                  );
                  _toggleFab();
                },
                label: const Text('Review'),
                icon: const Icon(Icons.rate_review),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 140.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'guess',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PredictionScreen()),
                  );
                  _toggleFab();
                },
                label: const Text('Guess'),
                icon: const Icon(Icons.help_outline),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          right: 16.0,
          bottom: _isFabExpanded ? 80.0 : 16.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isFabExpanded ? 1.0 : 0.0,
            child: SizedBox(
              width: 150,
              child: FloatingActionButton.extended(
                heroTag: 'suggest',
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SuggestionPage()),
                  );
                  _toggleFab();
                },
                label: const Text('Suggest'),
                icon: const Icon(Icons.edit),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 16.0,
          child: FloatingActionButton(
            heroTag: 'toggle',
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: _toggleFab,
            child: Icon(_isFabExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}