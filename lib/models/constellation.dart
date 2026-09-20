class Constellation {
  final String id;
  final String nameJa;
  final String nameEn;
  final String nameShort;
  final String category;
  final String rightAscension;
  final String declination;
  final List<String> brightStars;
  final List<String> brightStarsEn;
  final String peakMonths;
  final String peakMonthsEn;
  final String mythologyText;
  final String mythologyTextEn;
  final String emoji;
  final int baseDifficulty;
  final String observationTips;
  final String observationTipsEn;
  final String scientificData;
  final String scientificDataEn;
  final String funFacts;
  final String funFactsEn;

  const Constellation({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.nameShort,
    required this.category,
    required this.rightAscension,
    required this.declination,
    required this.brightStars,
    this.brightStarsEn = const [],
    required this.peakMonths,
    this.peakMonthsEn = '',
    required this.mythologyText,
    this.mythologyTextEn = '',
    required this.emoji,
    required this.baseDifficulty,
    this.observationTips = '',
    this.observationTipsEn = '',
    this.scientificData = '',
    this.scientificDataEn = '',
    this.funFacts = '',
    this.funFactsEn = '',
  });

  factory Constellation.fromJson(Map<String, dynamic> json) {
    return Constellation(
      id: json['id'] as String,
      nameJa: json['nameJa'] as String,
      nameEn: json['nameEn'] as String,
      nameShort: json['nameShort'] as String,
      category: json['category'] as String,
      rightAscension: json['rightAscension'] as String,
      declination: json['declination'] as String,
      brightStars: List<String>.from(json['brightStars'] as List),
      brightStarsEn: json['brightStarsEn'] != null
          ? List<String>.from(json['brightStarsEn'] as List)
          : const [],
      peakMonths: json['peakMonths'] as String,
      peakMonthsEn: json['peakMonthsEn'] as String? ?? '',
      mythologyText: json['mythologyText'] as String,
      mythologyTextEn: json['mythologyTextEn'] as String? ?? '',
      emoji: json['emoji'] as String,
      baseDifficulty: json['baseDifficulty'] as int,
      observationTips: json['observationTips'] as String? ?? '',
      observationTipsEn: json['observationTipsEn'] as String? ?? '',
      scientificData: json['scientificData'] as String? ?? '',
      scientificDataEn: json['scientificDataEn'] as String? ?? '',
      funFacts: json['funFacts'] as String? ?? '',
      funFactsEn: json['funFactsEn'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameJa': nameJa,
    'nameEn': nameEn,
    'nameShort': nameShort,
    'category': category,
    'rightAscension': rightAscension,
    'declination': declination,
    'brightStars': brightStars,
    'brightStarsEn': brightStarsEn,
    'peakMonths': peakMonths,
    'peakMonthsEn': peakMonthsEn,
    'mythologyText': mythologyText,
    'mythologyTextEn': mythologyTextEn,
    'emoji': emoji,
    'baseDifficulty': baseDifficulty,
    'observationTips': observationTips,
    'observationTipsEn': observationTipsEn,
    'scientificData': scientificData,
    'scientificDataEn': scientificDataEn,
    'funFacts': funFacts,
    'funFactsEn': funFactsEn,
  };

  /// [languageCode]が'en'かつ英語版のデータがある場合は英語、それ以外は日本語を返す。
  String localizedMythology(String languageCode) =>
      languageCode == 'en' && mythologyTextEn.isNotEmpty ? mythologyTextEn : mythologyText;

  String localizedObservationTips(String languageCode) =>
      languageCode == 'en' && observationTipsEn.isNotEmpty ? observationTipsEn : observationTips;

  String localizedScientificData(String languageCode) =>
      languageCode == 'en' && scientificDataEn.isNotEmpty ? scientificDataEn : scientificData;

  String localizedFunFacts(String languageCode) =>
      languageCode == 'en' && funFactsEn.isNotEmpty ? funFactsEn : funFacts;

  List<String> localizedBrightStars(String languageCode) =>
      languageCode == 'en' && brightStarsEn.isNotEmpty ? brightStarsEn : brightStars;

  String localizedPeakMonths(String languageCode) =>
      languageCode == 'en' && peakMonthsEn.isNotEmpty ? peakMonthsEn : peakMonths;

  /// [languageCode]が'en'の場合は英語名、それ以外は短縮日本語名を返す。
  String localizedShortName(String languageCode) =>
      languageCode == 'en' ? nameEn : nameShort;
}

class ConstellationCategory {
  static const String zodiac = 'zodiac';
  static const String northern = 'northern';
  static const String southern = 'southern';
}
