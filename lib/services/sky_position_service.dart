import 'dart:math' as math;

/// 地平座標（観測者から見た位置）
class HorizontalPosition {
  /// 高度（度）: 0=地平線, 90=天頂, 負値=地平線下（見えない）
  final double altitude;

  /// 方位角（度）: 0=北, 90=東, 180=南, 270=西
  final double azimuth;

  const HorizontalPosition({required this.altitude, required this.azimuth});

  bool get isVisible => altitude > 0;
}

/// 指定した日時・観測地から見た天体の位置を計算するサービス。
///
/// 星座の赤経(RA)・赤緯(Dec)はほぼ変化しないため「その星座の中心が今どこに
/// 見えるか」を地平座標（高度・方位角）に変換して求める。
/// 計算は簡易的な球面天文学の公式に基づく（分角程度の誤差は許容）。
class SkyPositionService {
  const SkyPositionService._();

  /// "02h 38m" 形式の赤経文字列を時間（0-24h）に変換
  static double parseRightAscensionHours(String ra) {
    final match = RegExp(r'(\d+)h\s*(\d+)m').firstMatch(ra);
    if (match == null) return 0;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    return h + m / 60.0;
  }

  /// "+20°" / "-65°" 形式の赤緯文字列を度に変換
  static double parseDeclinationDegrees(String dec) {
    final match = RegExp(r'([+-]?\d+)').firstMatch(dec);
    if (match == null) return 0;
    return double.parse(match.group(1)!);
  }

  /// ユリウス日 (Julian Date) を計算
  static double julianDate(DateTime utc) {
    final y = utc.year;
    final m = utc.month;
    final d = utc.day +
        (utc.hour + utc.minute / 60.0 + utc.second / 3600.0) / 24.0;
    int yy = y;
    int mm = m;
    if (mm <= 2) {
      yy -= 1;
      mm += 12;
    }
    final a = (yy / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (yy + 4716)).floor() +
        (30.6001 * (mm + 1)).floor() +
        d +
        b -
        1524.5;
  }

  /// グリニッジ平均恒星時 (GMST, 時間単位 0-24h)
  static double greenwichMeanSiderealTimeHours(DateTime utc) {
    final jd = julianDate(utc);
    final t = (jd - 2451545.0) / 36525.0;
    double gmst = 280.46061837 +
        360.98564736629 * (jd - 2451545.0) +
        0.000387933 * t * t -
        (t * t * t) / 38710000.0;
    gmst = gmst % 360.0;
    if (gmst < 0) gmst += 360.0;
    return gmst / 15.0; // 度→時間
  }

  /// 地方恒星時 (LST, 時間単位)。経度は東経を正とする。
  static double localSiderealTimeHours(DateTime utc, double longitudeDeg) {
    final gmst = greenwichMeanSiderealTimeHours(utc);
    double lst = gmst + longitudeDeg / 15.0;
    lst = lst % 24.0;
    if (lst < 0) lst += 24.0;
    return lst;
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;

  /// 赤道座標(RA時, Dec度)を、指定した観測地・日時での地平座標に変換する。
  ///
  /// [utc] は協定世界時。[latitudeDeg]/[longitudeDeg] は観測地の緯度・経度（度）。
  static HorizontalPosition equatorialToHorizontal({
    required double raHours,
    required double decDeg,
    required DateTime utc,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final lst = localSiderealTimeHours(utc, longitudeDeg);
    // 時角 (Hour Angle) を度に変換
    double haHours = lst - raHours;
    haHours = haHours % 24.0;
    if (haHours < 0) haHours += 24.0;
    final haDeg = haHours * 15.0;

    final ha = _deg2rad(haDeg);
    final dec = _deg2rad(decDeg);
    final lat = _deg2rad(latitudeDeg);

    final sinAlt =
        math.sin(dec) * math.sin(lat) + math.cos(dec) * math.cos(lat) * math.cos(ha);
    final alt = math.asin(sinAlt.clamp(-1.0, 1.0));

    final cosAz = (math.sin(dec) - math.sin(alt) * math.sin(lat)) /
        (math.cos(alt) * math.cos(lat));
    double az = math.acos(cosAz.clamp(-1.0, 1.0));
    // sin(HA) > 0 のとき天体は西側(方位角 > 180°)にある
    if (math.sin(ha) > 0) {
      az = 2 * math.pi - az;
    }

    return HorizontalPosition(
      altitude: _rad2deg(alt),
      azimuth: _rad2deg(az),
    );
  }

  /// 太陽の簡易位置（黄道座標→赤道座標の近似式、精度は数分角程度）
  static HorizontalPosition sunPosition({
    required DateTime utc,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final jd = julianDate(utc);
    final n = jd - 2451545.0;
    double l = (280.460 + 0.9856474 * n) % 360.0;
    if (l < 0) l += 360.0;
    double g = (357.528 + 0.9856003 * n) % 360.0;
    if (g < 0) g += 360.0;
    final gRad = _deg2rad(g);
    final lambda =
        l + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad);
    final lambdaRad = _deg2rad(lambda);
    final epsilon = _deg2rad(23.439 - 0.0000004 * n);

    final raRad = math.atan2(
        math.cos(epsilon) * math.sin(lambdaRad), math.cos(lambdaRad));
    double raHours = _rad2deg(raRad) / 15.0;
    if (raHours < 0) raHours += 24.0;
    final decDeg =
        _rad2deg(math.asin(math.sin(epsilon) * math.sin(lambdaRad)));

    return equatorialToHorizontal(
      raHours: raHours,
      decDeg: decDeg,
      utc: utc,
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
    );
  }

  /// 月の簡易位置（低精度近似式）
  static HorizontalPosition moonPosition({
    required DateTime utc,
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    final jd = julianDate(utc);
    final t = (jd - 2451545.0) / 36525.0;

    double lp = (218.3164477 +
            481267.88123421 * t -
            0.0015786 * t * t) %
        360.0;
    if (lp < 0) lp += 360.0;
    double d = (297.8501921 + 445267.1114034 * t) % 360.0;
    if (d < 0) d += 360.0;
    double m = (357.5291092 + 35999.0502909 * t) % 360.0;
    if (m < 0) m += 360.0;
    double mp = (134.9633964 + 477198.8675055 * t) % 360.0;
    if (mp < 0) mp += 360.0;

    final dRad = _deg2rad(d);
    final mpRad = _deg2rad(mp);
    final mRad = _deg2rad(m);

    // 主要な摂動項のみを使った簡易黄経補正（度）
    final lonCorrection = 6.289 * math.sin(mpRad) +
        1.274 * math.sin(2 * dRad - mpRad) +
        0.658 * math.sin(2 * dRad) -
        0.186 * math.sin(mRad);
    final latCorrection = 5.128 * math.sin(_deg2rad(93.272 +
        483202.0175233 * t));

    final lambda = lp + lonCorrection;
    final beta = latCorrection;

    final lambdaRad = _deg2rad(lambda);
    final betaRad = _deg2rad(beta);
    final epsilon = _deg2rad(23.439 - 0.0000004 * (jd - 2451545.0));

    final sinDec = math.sin(betaRad) * math.cos(epsilon) +
        math.cos(betaRad) * math.sin(epsilon) * math.sin(lambdaRad);
    final decRad = math.asin(sinDec.clamp(-1.0, 1.0));

    final y = math.sin(lambdaRad) * math.cos(epsilon) -
        math.tan(betaRad) * math.sin(epsilon);
    final x = math.cos(lambdaRad);
    double raRad = math.atan2(y, x);
    double raHours = _rad2deg(raRad) / 15.0;
    if (raHours < 0) raHours += 24.0;

    return equatorialToHorizontal(
      raHours: raHours,
      decDeg: _rad2deg(decRad),
      utc: utc,
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
    );
  }
}
