class Constellation {
  final String id;
  final String nameJa;
  final String nameEn;
  final String nameShort;
  final String category;
  final String rightAscension;
  final String declination;
  final List<String> brightStars;
  final String peakMonths;
  final String mythologyText;
  final String emoji;
  final int baseDifficulty;

  const Constellation({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.nameShort,
    required this.category,
    required this.rightAscension,
    required this.declination,
    required this.brightStars,
    required this.peakMonths,
    required this.mythologyText,
    required this.emoji,
    required this.baseDifficulty,
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
      peakMonths: json['peakMonths'] as String,
      mythologyText: json['mythologyText'] as String,
      emoji: json['emoji'] as String,
      baseDifficulty: json['baseDifficulty'] as int,
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
    'peakMonths': peakMonths,
    'mythologyText': mythologyText,
    'emoji': emoji,
    'baseDifficulty': baseDifficulty,
  };
}

class ConstellationCategory {
  static const String zodiac = 'zodiac';
  static const String northern = 'northern';
  static const String southern = 'southern';
}
