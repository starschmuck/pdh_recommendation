import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String? _selectedMealId;
  String? _selectedMealName;
  Map<String, String> _optionsIdToName = const {};

  bool _loadingExisting = true;
  bool _hasExistingPrediction = false;
  String? _existingMealName;

  DateTime get _tomorrow => DateTime.now().add(const Duration(days: 1));
  String get _dateKey => _yyyyMmDd(_tomorrow);

  String _yyyyMmDd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _loadExistingPrediction();
  }

  Future<void> _loadExistingPrediction() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loadingExisting = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('predictions')
          .doc(_dateKey)
          .collection('users')
          .doc(uid)
          .get();

      if (snap.exists) {
        final data = snap.data() ?? {};
        setState(() {
          _hasExistingPrediction = true;
          _existingMealName =
              (data['mealName'] ?? data['mealId'] ?? 'Your pick').toString();
          _selectedMealId = (data['mealId'] as String?);
          _selectedMealName = _existingMealName;
        });
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loadingExisting = false);
    }
  }

  Stream<QuerySnapshot> _mealStream() {
    return FirebaseFirestore.instance
        .collection('meals')
        .doc(_dateKey)
        .collection('meals')
        .snapshots();
  }

  Future<void> _submit() async {
    if (_selectedMealId == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a prediction.')),
      );
      return;
    }

    final predRef = FirebaseFirestore.instance
        .collection('predictions')
        .doc(_dateKey)
        .collection('users')
        .doc(uid);

    final mealName =
        _selectedMealName ?? _optionsIdToName[_selectedMealId!] ?? _selectedMealId!;

    try {
      // Overwrite or create prediction (owner can change their pick)
      await predRef.set({
        'mealId': _selectedMealId,
        'mealName': mealName,
        'updatedAt': FieldValue.serverTimestamp(),
        // Keep pointsAwarded false for this date to ensure scorer can award later
        'pointsAwarded': false,
        // Set createdAt if missing
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prediction saved for $_dateKey: $mealName')),
      );
      Navigator.of(context).pop(); // return to previous screen on success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving prediction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExisting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict Tomorrow'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _mealStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(child: Text('No meals found for $_dateKey.'));
            }

            String labelFor(Map<String, dynamic> data, String fallback) {
              return (data['name'] ??
                      data['title'] ??
                      data['mealName'] ??
                      fallback)
                  .toString();
            }

            // Deduplicate by normalized meal name (keep first occurrence)
            final Map<String, QueryDocumentSnapshot> uniqueByName = {};
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final label = labelFor(data, doc.id);
              final key = label.toLowerCase().trim();
              uniqueByName.putIfAbsent(key, () => doc);
            }

            // Sort alphabetically by display label
            final sortedEntries = uniqueByName.entries.toList()
              ..sort((a, b) {
                final aData = (a.value.data() as Map<String, dynamic>? ?? {});
                final bData = (b.value.data() as Map<String, dynamic>? ?? {});
                final aLabel = labelFor(aData, a.value.id).toLowerCase();
                final bLabel = labelFor(bData, b.value.id).toLowerCase();
                return aLabel.compareTo(bLabel);
              });

            // Build id->name map for submit lookups
            _optionsIdToName = {
              for (final e in sortedEntries)
                e.value.id: labelFor(
                  (e.value.data() as Map<String, dynamic>? ?? {}),
                  e.value.id,
                )
            };

            // Keep selection valid; if the saved id was deduped out, remap by name
            final validIds = _optionsIdToName.keys.toSet();
            if (_selectedMealId != null && !validIds.contains(_selectedMealId)) {
              if (_existingMealName != null) {
                final match = sortedEntries.firstWhere(
                  (e) {
                    final nm = labelFor(
                      (e.value.data() as Map<String, dynamic>? ?? {}),
                      e.value.id,
                    );
                    return nm.toLowerCase().trim() ==
                        _existingMealName!.toLowerCase().trim();
                  },
                  orElse: () => null as dynamic,
                );
                _selectedMealId = match.value.id;
                _selectedMealName = _optionsIdToName[_selectedMealId!];
                            } else {
                _selectedMealId = null;
                _selectedMealName = null;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meals for $_dateKey',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                if (_hasExistingPrediction && _existingMealName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current prediction: $_existingMealName\nSubmit again to change it.',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMealId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Choose your prediction',
                    border: OutlineInputBorder(),
                  ),
                  items: sortedEntries.map((entry) {
                    final data = entry.value.data() as Map<String, dynamic>? ?? {};
                    final label = labelFor(data, entry.value.id);
                    return DropdownMenuItem<String>(
                      value: entry.value.id,
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMealId = val;
                      _selectedMealName =
                          val != null ? _optionsIdToName[val] : null;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pick the meal you think will be the highest rated tomorrow.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _selectedMealId == null ? null : _submit,
          icon: const Icon(Icons.check),
          label: Text(_hasExistingPrediction ? 'Update Prediction' : 'Submit Prediction'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}