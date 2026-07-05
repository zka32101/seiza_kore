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

/// Complete stars database covering all 88 constellations
final constellationStarMap = {
  // 黄道12星座
  'aries': const StarData(name: 'ハマル', nameEn: 'Hamal', lightYears: 66.0, constellationId: 'aries'),
  'taurus': const StarData(name: 'アルデバラン', nameEn: 'Aldebaran', lightYears: 65.1, constellationId: 'taurus'),
  'gemini': const StarData(name: 'ポルックス', nameEn: 'Pollux', lightYears: 34.0, constellationId: 'gemini'),
  'cancer': const StarData(name: 'レギュラス', nameEn: 'Regulus', lightYears: 77.0, constellationId: 'cancer'),
  'leo': const StarData(name: 'レギュラス', nameEn: 'Regulus', lightYears: 77.0, constellationId: 'leo'),
  'virgo': const StarData(name: 'スピカ', nameEn: 'Spica', lightYears: 250.0, constellationId: 'virgo'),
  'libra': const StarData(name: 'ズベンエルジェナビ', nameEn: 'Zubenelgenubi', lightYears: 77.0, constellationId: 'libra'),
  'scorpius': const StarData(name: 'アンタレス', nameEn: 'Antares', lightYears: 554.0, constellationId: 'scorpius'),
  'sagittarius': const StarData(name: 'ヌス', nameEn: 'Kaus Australis', lightYears: 88.0, constellationId: 'sagittarius'),
  'capricornus': const StarData(name: 'デネブアルゲディ', nameEn: 'Deneb Algedi', lightYears: 39.0, constellationId: 'capricornus'),
  'aquarius': const StarData(name: 'サダルスード', nameEn: 'Sadalsuud', lightYears: 540.0, constellationId: 'aquarius'),
  'pisces': const StarData(name: 'エタ・プリスキマ', nameEn: 'Eta Piscium', lightYears: 294.0, constellationId: 'pisces'),

  // 北天の星座
  'ursa_major': const StarData(name: 'アルクトゥルス', nameEn: 'Arcturus', lightYears: 37.0, constellationId: 'ursa_major'),
  'ursa_minor': const StarData(name: 'ポーラリス', nameEn: 'Polaris', lightYears: 431.0, constellationId: 'ursa_minor'),
  'draco': const StarData(name: 'エルタニン', nameEn: 'Eltanin', lightYears: 154.0, constellationId: 'draco'),
  'cassiopeia': const StarData(name: 'シェダル', nameEn: 'Schedar', lightYears: 230.0, constellationId: 'cassiopeia'),
  'cepheus': const StarData(name: 'アルデラミン', nameEn: 'Alderamin', lightYears: 49.0, constellationId: 'cepheus'),
  'perseus': const StarData(name: 'ミルファク', nameEn: 'Mirfak', lightYears: 510.0, constellationId: 'perseus'),
  'camelopardalis': const StarData(name: 'ベータ・カメロパルダリス', nameEn: 'Beta Camelopardalis', lightYears: 50.0, constellationId: 'camelopardalis'),
  'lynx': const StarData(name: 'アルファ・リンクス', nameEn: 'Alpha Lynx', lightYears: 203.0, constellationId: 'lynx'),

  // 夏の大三角形周辺
  'lyra': const StarData(name: 'ベガ', nameEn: 'Vega', lightYears: 25.0, constellationId: 'lyra'),
  'cygnus': const StarData(name: 'デネブ', nameEn: 'Deneb', lightYears: 2600.0, constellationId: 'cygnus'),
  'aquila': const StarData(name: 'アルタイル', nameEn: 'Altair', lightYears: 16.7, constellationId: 'aquila'),
  'sagitta': const StarData(name: 'ガンマ・サギッタ', nameEn: 'Gamma Sagitta', lightYears: 273.0, constellationId: 'sagitta'),
  'vulpecula': const StarData(name: 'アルファ・ヴァルペキュラ', nameEn: 'Alpha Vulpeculae', lightYears: 240.0, constellationId: 'vulpecula'),

  // ペルセウス座周辺
  'andromeda': const StarData(name: 'アルフェラッツ', nameEn: 'Alpheratz', lightYears: 97.0, constellationId: 'andromeda'),
  'triangulum': const StarData(name: 'ベータ・トリアングリ', nameEn: 'Beta Trianguli', lightYears: 127.0, constellationId: 'triangulum'),
  'auriga': const StarData(name: 'カペラ', nameEn: 'Capella', lightYears: 42.0, constellationId: 'auriga'),

  // 冬の大三角形周辺
  'orion': const StarData(name: 'ベテルギウス', nameEn: 'Betelgeuse', lightYears: 640.0, constellationId: 'orion'),
  'canis_major': const StarData(name: 'シリウス', nameEn: 'Sirius', lightYears: 8.6, constellationId: 'canis_major'),
  'canis_minor': const StarData(name: 'プロキオン', nameEn: 'Procyon', lightYears: 11.4, constellationId: 'canis_minor'),
  'monoceros': const StarData(name: 'アルファ・モノケロティス', nameEn: 'Alpha Monocerotis', lightYears: 48.0, constellationId: 'monoceros'),
  'lepus': const StarData(name: 'アルニテク', nameEn: 'Arneb', lightYears: 2270.0, constellationId: 'lepus'),
  'columba': const StarData(name: 'ファイアド', nameEn: 'Phact', lightYears: 268.0, constellationId: 'columba'),

  // 南天の星座
  'carina': const StarData(name: 'カノープス', nameEn: 'Canopus', lightYears: 309.0, constellationId: 'carina'),
  'puppis': const StarData(name: 'ナオス', nameEn: 'Naos', lightYears: 1080.0, constellationId: 'puppis'),
  'pyxis': const StarData(name: 'アルファ・ピクシス', nameEn: 'Alpha Pyxidis', lightYears: 880.0, constellationId: 'pyxis'),
  'vela': const StarData(name: 'ガンマ・ベロラム', nameEn: 'Gamma Velorum', lightYears: 840.0, constellationId: 'vela'),
  'centaurus': const StarData(name: 'アルファ・ケンタウリ', nameEn: 'Alpha Centauri', lightYears: 4.4, constellationId: 'centaurus'),
  'lupus': const StarData(name: 'アルファ・ルピ', nameEn: 'Alpha Lupi', lightYears: 660.0, constellationId: 'lupus'),
  'ara': const StarData(name: 'アルファ・アラエ', nameEn: 'Alpha Arae', lightYears: 242.0, constellationId: 'ara'),
  'triangulum_australe': const StarData(name: 'アトリア', nameEn: 'Atria', lightYears: 415.0, constellationId: 'triangulum_australe'),
  'norma': const StarData(name: 'ガンマ・ノルマエ', nameEn: 'Gamma Normae', lightYears: 134.0, constellationId: 'norma'),
  'circinus': const StarData(name: 'アルファ・キルチニ', nameEn: 'Alpha Circini', lightYears: 54.0, constellationId: 'circinus'),
  'musca': const StarData(name: 'アルファ・ムスカエ', nameEn: 'Alpha Muscae', lightYears: 313.0, constellationId: 'musca'),
  'crux': const StarData(name: 'アクルックス', nameEn: 'Acrux', lightYears: 321.0, constellationId: 'crux'),
  'corvus': const StarData(name: 'ガンマ・コルビ', nameEn: 'Gamma Corvi', lightYears: 88.0, constellationId: 'corvus'),
  'crater': const StarData(name: 'デルタ・クラテリス', nameEn: 'Delta Crateris', lightYears: 195.0, constellationId: 'crater'),
  'hydra': const StarData(name: 'アルファ・ヒドラエ', nameEn: 'Alphard', lightYears: 177.0, constellationId: 'hydra'),
  'antlia': const StarData(name: 'アルファ・アンティアエ', nameEn: 'Alpha Antliae', lightYears: 408.0, constellationId: 'antlia'),

  // その他の星座
  'bootes': const StarData(name: 'アルクトゥルス', nameEn: 'Arcturus', lightYears: 37.0, constellationId: 'bootes'),
  'corona_borealis': const StarData(name: 'アルファ・コロナエ・ボレアリス', nameEn: 'Alphecca', lightYears: 75.0, constellationId: 'corona_borealis'),
  'hercules': const StarData(name: 'アルフェッカ', nameEn: 'Ras Algethi', lightYears: 520.0, constellationId: 'hercules'),
  'ophiuchus': const StarData(name: 'ラス・アルゲティ', nameEn: 'Ras Alhague', lightYears: 48.0, constellationId: 'ophiuchus'),
  'serpens': const StarData(name: 'アンクア', nameEn: 'Unukalhai', lightYears: 74.0, constellationId: 'serpens'),
  'scutum': const StarData(name: 'アルファ・スクティ', nameEn: 'Alpha Scuti', lightYears: 185.0, constellationId: 'scutum'),

  // 秋の星座
  'pegasus': const StarData(name: 'エニフ', nameEn: 'Enif', lightYears: 2700.0, constellationId: 'pegasus'),
  'cetus': const StarData(name: 'ミラ', nameEn: 'Mira', lightYears: 305.0, constellationId: 'cetus'),
  'aries': const StarData(name: 'ハマル', nameEn: 'Hamal', lightYears: 66.0, constellationId: 'aries'),
  'fornax': const StarData(name: 'アルファ・フォルナキス', nameEn: 'Alpha Fornacis', lightYears: 46.0, constellationId: 'fornax'),
  'sculptor': const StarData(name: 'アルファ・スクルプトリス', nameEn: 'Alpha Sculptoris', lightYears: 74.0, constellationId: 'sculptor'),

  // 春の星座
  'canes_venatici': const StarData(name: 'コル・カロリ', nameEn: 'Cor Caroli', lightYears: 115.0, constellationId: 'canes_venatici'),
  'coma_berenices': const StarData(name: 'デネボラ', nameEn: 'Denebola', lightYears: 36.0, constellationId: 'coma_berenices'),
  'leo_minor': const StarData(name: 'プラエキプス', nameEn: 'Praecipua', lightYears: 228.0, constellationId: 'leo_minor'),
  'cancer': const StarData(name: 'アクベンス', nameEn: 'Acubens', lightYears: 174.0, constellationId: 'cancer'),

  // その他の星座（南天・小星座）
  'delphinus': const StarData(name: 'スヴァロッキン', nameEn: 'Svalockin', lightYears: 67.0, constellationId: 'delphinus'),
  'equuleus': const StarData(name: 'キタルペ', nameEn: 'Kitalpe', lightYears: 191.0, constellationId: 'equuleus'),
  'eridanus': const StarData(name: 'アケルナル', nameEn: 'Achernar', lightYears: 139.0, constellationId: 'eridanus'),
  'piscis_austrinus': const StarData(name: 'フォーマルハウト', nameEn: 'Fomalhaut', lightYears: 25.0, constellationId: 'piscis_austrinus'),
  'pavo': const StarData(name: 'アルファ・パヴォニス', nameEn: 'Alpha Pavonis', lightYears: 183.0, constellationId: 'pavo'),
  'grus': const StarData(name: 'アルナイル', nameEn: 'Alnair', lightYears: 101.0, constellationId: 'grus'),
  'phoenix': const StarData(name: 'アンクマ', nameEn: 'Ankaa', lightYears: 89.0, constellationId: 'phoenix'),
  'tucana': const StarData(name: 'アルファ・トゥカナエ', nameEn: 'Alpha Tucanae', lightYears: 200.0, constellationId: 'tucana'),
  'dorado': const StarData(name: 'アルファ・ドラドゥス', nameEn: 'Alpha Doradus', lightYears: 176.0, constellationId: 'dorado'),
  'corona_australis': const StarData(name: 'アルファ・コロナエ・アウストラリス', nameEn: 'Alphecca Australis', lightYears: 130.0, constellationId: 'corona_australis'),
  'telescopium': const StarData(name: 'アルファ・テレスコピイ', nameEn: 'Alpha Telescopii', lightYears: 282.0, constellationId: 'telescopium'),
  'microscopium': const StarData(name: 'ガンマ・ミクロスコピイ', nameEn: 'Gamma Microscopii', lightYears: 328.0, constellationId: 'microscopium'),
  'horologium': const StarData(name: 'アルファ・ホロロギイ', nameEn: 'Alpha Horologi', lightYears: 117.0, constellationId: 'horologium'),
  'reticulum': const StarData(name: 'アルファ・レティクリ', nameEn: 'Alpha Reticuli', lightYears: 161.0, constellationId: 'reticulum'),
  'pictor': const StarData(name: 'アルファ・ピクトリス', nameEn: 'Alpha Pictoris', lightYears: 97.0, constellationId: 'pictor'),
  'hydrus': const StarData(name: 'ベータ・ヒドリ', nameEn: 'Beta Hydri', lightYears: 36.0, constellationId: 'hydrus'),
  'indus': const StarData(name: 'アルファ・インディ', nameEn: 'Alpha Indi', lightYears: 102.0, constellationId: 'indus'),
  'apus': const StarData(name: 'アルファ・アプス', nameEn: 'Alpha Apodis', lightYears: 411.0, constellationId: 'apus'),
  'octans': const StarData(name: 'ヌー・オクタンティス', nameEn: 'Nu Octantis', lightYears: 71.0, constellationId: 'octans'),
  'mensa': const StarData(name: 'アルファ・メンサエ', nameEn: 'Alpha Mensae', lightYears: 33.0, constellationId: 'mensa'),
  'volans': const StarData(name: 'ガンマ・ヴォランティス', nameEn: 'Gamma Volantis', lightYears: 202.0, constellationId: 'volans'),
  'chamaeleon': const StarData(name: 'アルファ・カメレオンティス', nameEn: 'Alpha Chamaeleontis', lightYears: 196.0, constellationId: 'chamaeleon'),
  'sextans': const StarData(name: 'アルファ・セクスタンティス', nameEn: 'Alpha Sextantis', lightYears: 262.0, constellationId: 'sextans'),
  'caelum': const StarData(name: 'アルファ・カエリ', nameEn: 'Alpha Caeli', lightYears: 179.0, constellationId: 'caelum'),
  'lacerta': const StarData(name: 'アルファ・ラケルタエ', nameEn: 'Alpha Lacertae', lightYears: 102.0, constellationId: 'lacerta'),
};

/// Primary stars database with light-year distances (kept for compatibility)
final starsDatabase = constellationStarMap;

/// Get star data by constellation ID
StarData? getStarDataByConstellationId(String constellationId) {
  return constellationStarMap[constellationId];
}
