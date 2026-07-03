/// Constellation light-year and distance data for "Light-year Time Travel" feature
class StarData {
  final String name;
  final String nameEn;
  final double lightYears;
  final String constellationId;

  const StarData({
    required this.name,
    required this.nameEn,
    required this.lightYears,
    required this.constellationId,
  });

  /// Calculate the year light was emitted from this star
  int getOriginYear(int observationYear) {
    return observationYear - lightYears.toInt();
  }

  /// Get human-readable description of light travel
  String getLightYearDescription() {
    if (lightYears < 1) {
      return '${(lightYears * 12).toInt()}ヶ月の光の旅';
    } else if (lightYears < 1000) {
      return '${lightYears.toStringAsFixed(1)}光年の光の旅';
    } else {
      return '${(lightYears / 1000).toStringAsFixed(1)}千光年の光の旅';
    }
  }
}

/// Primary stars database with light-year distances
final starsDatabase = {
  // 白い星（主系列星、温度高）
  'sirius': const StarData(
    name: 'シリウス',
    nameEn: 'Sirius',
    lightYears: 8.6,
    constellationId: 'canis_major',
  ),
  'vega': const StarData(
    name: 'ベガ',
    nameEn: 'Vega',
    lightYears: 25.0,
    constellationId: 'lyra',
  ),
  'altair': const StarData(
    name: 'アルタイル',
    nameEn: 'Altair',
    lightYears: 16.7,
    constellationId: 'aquila',
  ),

  // 赤色巨星（低温）
  'betelgeuse': const StarData(
    name: 'ベテルギウス',
    nameEn: 'Betelgeuse',
    lightYears: 640.0,
    constellationId: 'orion',
  ),
  'aldebaran': const StarData(
    name: 'アルデバラン',
    nameEn: 'Aldebaran',
    lightYears: 65.1,
    constellationId: 'taurus',
  ),
  'antares': const StarData(
    name: 'アンタレス',
    nameEn: 'Antares',
    lightYears: 554.0,
    constellationId: 'scorpius',
  ),

  // 極度に遠い星
  'polaris': const StarData(
    name: 'ポーラリス（北極星）',
    nameEn: 'Polaris',
    lightYears: 431.0,
    constellationId: 'ursa_minor',
  ),
  'deneb': const StarData(
    name: 'デネブ',
    nameEn: 'Deneb',
    lightYears: 2600.0,
    constellationId: 'cygnus',
  ),

  // 黄色星
  'pollux': const StarData(
    name: 'ポルックス',
    nameEn: 'Pollux',
    lightYears: 34.0,
    constellationId: 'gemini',
  ),
  'procyon': const StarData(
    name: 'プロキオン',
    nameEn: 'Procyon',
    lightYears: 11.4,
    constellationId: 'canis_minor',
  ),

  // ライラの星々
  'epsilon_lyrae': const StarData(
    name: 'イプシロン・ライラエ',
    nameEn: 'Epsilon Lyrae',
    lightYears: 162.0,
    constellationId: 'lyra',
  ),

  // その他
  'rigel': const StarData(
    name: 'リゲル',
    nameEn: 'Rigel',
    lightYears: 863.0,
    constellationId: 'orion',
  ),
  'canopus': const StarData(
    name: 'カノープス',
    nameEn: 'Canopus',
    lightYears: 309.0,
    constellationId: 'carina',
  ),
};

/// Get star data by constellation ID
StarData? getStarDataByConstellationId(String constellationId) {
  try {
    return starsDatabase.values.firstWhere(
      (star) => star.constellationId == constellationId,
    );
  } catch (e) {
    return null;
  }
}
