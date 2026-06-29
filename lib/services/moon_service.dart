class MoonService {
  static const double _synodicPeriod = 29.53059;
  // 2026-01-29 12:36 UTC is a known new moon
  static final DateTime _referenceNewMoon = DateTime.utc(2026, 1, 29, 12, 36);

  static double moonAge(DateTime date) {
    final diff = date.toUtc().difference(_referenceNewMoon);
    final days = diff.inMilliseconds / 86400000.0;
    return ((days % _synodicPeriod) + _synodicPeriod) % _synodicPeriod;
  }

  static String moonPhaseEmoji(double age) {
    if (age < 1.85) return '🌑';
    if (age < 5.54) return '🌒';
    if (age < 9.22) return '🌓';
    if (age < 12.91) return '🌔';
    if (age < 16.61) return '🌕';
    if (age < 20.30) return '🌖';
    if (age < 23.99) return '🌗';
    if (age < 27.68) return '🌘';
    return '🌑';
  }

  static String moonPhaseName(double age) {
    if (age < 1.85) return '新月';
    if (age < 5.54) return '三日月';
    if (age < 9.22) return '上弦の月';
    if (age < 12.91) return '十三夜月';
    if (age < 16.61) return '満月';
    if (age < 20.30) return '十六夜';
    if (age < 23.99) return '下弦の月';
    if (age < 27.68) return '有明月';
    return '新月';
  }

  // 月が暗いほど星座観測に向いている (age<7 or age>22)
  static bool isGoodForObservation(double age) => age < 7 || age > 22;
}
