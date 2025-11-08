/// Data model for a user suggestion.
/// Matches DB schema and adds optional recipeLink.
class Suggestion {
  final String suggestionId;     // DB: suggestionId
  final String title;            // DB: title
  final String suggestionText;   // DB: suggestionText
  final String userId;           // DB: userId
  final DateTime timestamp;      // DB: timestamp (stored as ms since epoch)
  final String? recipeLink;      // DB: recipeLink (optional)

  const Suggestion({
    required this.suggestionId,
    required this.title,
    required this.suggestionText,
    required this.userId,
    required this.timestamp,
    this.recipeLink,
  });

  Suggestion copyWith({
    String? suggestionId,
    String? title,
    String? suggestionText,
    String? userId,
    DateTime? timestamp,
    String? recipeLink,
  }) {
    return Suggestion(
      suggestionId: suggestionId ?? this.suggestionId,
      title: title ?? this.title,
      suggestionText: suggestionText ?? this.suggestionText,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
      recipeLink: recipeLink ?? this.recipeLink,
    );
  }

  /// Serialize for DB write. Keeps existing schema and adds recipeLink only if present.
  Map<String, dynamic> toMap() {
    return {
      'suggestionId': suggestionId,
      'title': title,
      'suggestionText': suggestionText,
      'userId': userId,
      // store as millis since epoch for both RTDB/Firestore portability
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (recipeLink != null && recipeLink!.isNotEmpty) 'recipeLink': recipeLink,
    };
  }

  /// Read from DB snapshot map.
  factory Suggestion.fromMap(Map<String, dynamic> map) {
    return Suggestion(
      suggestionId: (map['suggestionId'] ?? map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      suggestionText: (map['suggestionText'] ?? map['text'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      timestamp: _parseTimestamp(map['timestamp']),
      recipeLink: (map['recipeLink'] as String?)?.trim(),
    );
  }

  /// Optional JSON helpers
  Map<String, dynamic> toJson() => toMap();
  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion.fromMap(json);

  static DateTime _parseTimestamp(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    // Firestore Timestamp-like map support (seconds/nanoseconds)
    if (v is Map && (v.containsKey('seconds') || v.containsKey('_seconds'))) {
      final seconds = (v['seconds'] ?? v['_seconds']) as num? ?? 0;
      final nanos = (v['nanoseconds'] ?? v['_nanoseconds']) as num? ?? 0;
      final ms = (seconds * 1000).round() + (nanos / 1e6).round();
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return DateTime.now();
  }
}