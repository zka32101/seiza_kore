class Observation {
  final String id;
  final String constellationId;
  final DateTime timestamp;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final int bortleScale;
  final String weather;
  final String notes;
  final List<String> photoUrls;

  const Observation({
    required this.id,
    required this.constellationId,
    required this.timestamp,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.bortleScale,
    required this.weather,
    required this.notes,
    required this.photoUrls,
  });

  int get difficultyStars {
    if (bortleScale >= 7) return 3;
    if (bortleScale >= 4) return 2;
    return 1;
  }

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id'] as String,
      constellationId: json['constellationId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      locationName: json['locationName'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      bortleScale: json['bortleScale'] as int,
      weather: json['weather'] as String,
      notes: json['notes'] as String,
      photoUrls: List<String>.from(json['photoUrls'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'constellationId': constellationId,
    'timestamp': timestamp.toIso8601String(),
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'bortleScale': bortleScale,
    'weather': weather,
    'notes': notes,
    'photoUrls': photoUrls,
  };

  /// [languageCode]が'en'の場合、保存されている天気の値（日本語）を英語表示名に変換する。
  /// 対応表にない値（自由記述等）はそのまま返す。
  String localizedWeather(String languageCode) =>
      languageCode == 'en' ? (weatherLabelsEn[weather] ?? weather) : weather;
}

const List<String> weatherOptions = ['晴れ', '薄曇り', '曇り', '快晴'];

const Map<String, String> weatherLabelsEn = {
  '晴れ': 'Sunny',
  '薄曇り': 'Slightly Cloudy',
  '曇り': 'Cloudy',
  '快晴': 'Clear',
};
