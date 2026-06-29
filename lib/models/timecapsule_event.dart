class TimecapsuleEvent {
  final String id;
  final String name;
  final String type;
  final DateTime openTime;
  final DateTime closeTime;
  final String description;
  final String emoji;

  const TimecapsuleEvent({
    required this.id,
    required this.name,
    required this.type,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.emoji,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  bool get isUpcoming => DateTime.now().isBefore(openTime);

  bool get isPast => DateTime.now().isAfter(closeTime);

  Duration get timeUntilOpen => openTime.difference(DateTime.now());

  int get daysUntilOpen => timeUntilOpen.inDays;
}

class TimecapsuleRecord {
  final String id;
  final String eventId;
  final DateTime observedAt;
  final int meteorCount;
  final String notes;
  final List<String> photoUrls;

  const TimecapsuleRecord({
    required this.id,
    required this.eventId,
    required this.observedAt,
    required this.meteorCount,
    required this.notes,
    required this.photoUrls,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'observedAt': observedAt.toIso8601String(),
        'meteorCount': meteorCount,
        'notes': notes,
        'photoUrls': photoUrls,
      };

  factory TimecapsuleRecord.fromJson(Map<String, dynamic> json) =>
      TimecapsuleRecord(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        observedAt: DateTime.parse(json['observedAt'] as String),
        meteorCount: json['meteorCount'] as int,
        notes: json['notes'] as String,
        photoUrls: (json['photoUrls'] as List).cast<String>(),
      );
}

class TimecapsuleEventType {
  static const String meteor = 'meteor';
  static const String eclipse = 'eclipse';
  static const String conjunction = 'conjunction';
  static const String special = 'special';
}
