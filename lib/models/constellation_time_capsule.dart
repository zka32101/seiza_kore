import 'package:intl/intl.dart';

/// Constellation Time Capsule - save observations for future reveal
class ConstellationTimeCapsule {
  final String id;
  final String constellationId;
  final String constellationName;
  final DateTime recordedAt; // When the observation was made
  final DateTime releaseDate; // When this capsule unlocks
  final String message; // User's personal message
  final int bortleScale; // Light pollution level at observation
  final String locationName;
  final String emoji;

  ConstellationTimeCapsule({
    required this.id,
    required this.constellationId,
    required this.constellationName,
    required this.recordedAt,
    required this.releaseDate,
    required this.message,
    required this.bortleScale,
    required this.locationName,
    required this.emoji,
  });

  /// Evaluated against the current time on every access, so unlock state
  /// stays correct even if the app stays open across the release moment.
  bool get isUnlocked => DateTime.now().isAfter(releaseDate);

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'constellationId': constellationId,
      'constellationName': constellationName,
      'recordedAt': recordedAt.toIso8601String(),
      'releaseDate': releaseDate.toIso8601String(),
      'message': message,
      'bortleScale': bortleScale,
      'locationName': locationName,
      'emoji': emoji,
    };
  }

  /// Create from JSON
  factory ConstellationTimeCapsule.fromJson(Map<String, dynamic> json) {
    return ConstellationTimeCapsule(
      id: json['id'] as String,
      constellationId: json['constellationId'] as String,
      constellationName: json['constellationName'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      releaseDate: DateTime.parse(json['releaseDate'] as String),
      message: json['message'] as String? ?? '',
      bortleScale: json['bortleScale'] as int? ?? 5,
      locationName: json['locationName'] as String? ?? '不明',
      emoji: json['emoji'] as String? ?? '⭐',
    );
  }

  /// Get formatted release date
  String getFormattedReleaseDate() {
    return DateFormat('yyyy年M月d日').format(releaseDate);
  }

  /// Get days until release
  int getDaysUntilRelease() {
    final now = DateTime.now();
    if (isUnlocked) return 0;
    return releaseDate.difference(now).inDays + 1;
  }

  /// Get release status message
  String getReleaseStatus() {
    if (isUnlocked) {
      return '解放済み ✨';
    } else {
      final days = getDaysUntilRelease();
      return '残り $days 日で解放';
    }
  }

  /// Copy with modifications
  ConstellationTimeCapsule copyWith({
    String? id,
    String? constellationId,
    String? constellationName,
    DateTime? recordedAt,
    DateTime? releaseDate,
    String? message,
    int? bortleScale,
    String? locationName,
    String? emoji,
  }) {
    return ConstellationTimeCapsule(
      id: id ?? this.id,
      constellationId: constellationId ?? this.constellationId,
      constellationName: constellationName ?? this.constellationName,
      recordedAt: recordedAt ?? this.recordedAt,
      releaseDate: releaseDate ?? this.releaseDate,
      message: message ?? this.message,
      bortleScale: bortleScale ?? this.bortleScale,
      locationName: locationName ?? this.locationName,
      emoji: emoji ?? this.emoji,
    );
  }
}
