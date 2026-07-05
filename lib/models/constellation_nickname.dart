/// Custom nickname for a discovered constellation
class ConstellationNickname {
  final String constellationId;
  final String nickname;
  final String reason; // Why the user gave this nickname
  final DateTime createdAt;

  const ConstellationNickname({
    required this.constellationId,
    required this.nickname,
    required this.reason,
    required this.createdAt,
  });

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'constellationId': constellationId,
      'nickname': nickname,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ConstellationNickname.fromJson(Map<String, dynamic> json) {
    return ConstellationNickname(
      constellationId: json['constellationId'] as String,
      nickname: json['nickname'] as String,
      reason: json['reason'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Copy with modifications
  ConstellationNickname copyWith({
    String? constellationId,
    String? nickname,
    String? reason,
    DateTime? createdAt,
  }) {
    return ConstellationNickname(
      constellationId: constellationId ?? this.constellationId,
      nickname: nickname ?? this.nickname,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConstellationNickname &&
          runtimeType == other.runtimeType &&
          constellationId == other.constellationId;

  @override
  int get hashCode => constellationId.hashCode;
}
