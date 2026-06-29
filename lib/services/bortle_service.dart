class BortleService {
  static const BortleService instance = BortleService._();
  const BortleService._();

  // 日本の主要都市・地域のBortleスケール近似値（v1.0 簡易版）
  // 緯度・経度の矩形エリアでマッピング
  static const List<_BortleRegion> _regions = [
    // 東京都心
    _BortleRegion(latMin: 35.6, latMax: 35.75, lonMin: 139.6, lonMax: 139.85, scale: 9, name: '東京都心'),
    // 大阪・梅田
    _BortleRegion(latMin: 34.6, latMax: 34.75, lonMin: 135.4, lonMax: 135.6, scale: 9, name: '大阪市内'),
    // 横浜
    _BortleRegion(latMin: 35.4, latMax: 35.5, lonMin: 139.6, lonMax: 139.7, scale: 8, name: '横浜市'),
    // 名古屋
    _BortleRegion(latMin: 35.1, latMax: 35.25, lonMin: 136.8, lonMax: 137.0, scale: 9, name: '名古屋市'),
    // 福岡
    _BortleRegion(latMin: 33.5, latMax: 33.65, lonMin: 130.3, lonMax: 130.5, scale: 8, name: '福岡市'),
    // 札幌
    _BortleRegion(latMin: 43.0, latMax: 43.15, lonMin: 141.2, lonMax: 141.45, scale: 8, name: '札幌市'),
    // 仙台
    _BortleRegion(latMin: 38.2, latMax: 38.35, lonMin: 140.8, lonMax: 141.0, scale: 7, name: '仙台市'),
    // 京都
    _BortleRegion(latMin: 34.9, latMax: 35.1, lonMin: 135.7, lonMax: 135.85, scale: 8, name: '京都市'),
    // 千葉郊外
    _BortleRegion(latMin: 35.5, latMax: 35.75, lonMin: 139.9, lonMax: 140.2, scale: 7, name: '千葉郊外'),
    // 埼玉郊外
    _BortleRegion(latMin: 35.75, latMax: 36.0, lonMin: 139.4, lonMax: 139.65, scale: 7, name: '埼玉郊外'),
    // 長野県（山岳）
    _BortleRegion(latMin: 35.9, latMax: 36.5, lonMin: 137.5, lonMax: 138.5, scale: 3, name: '長野山岳部'),
    // 長野市周辺
    _BortleRegion(latMin: 36.5, latMax: 36.7, lonMin: 138.1, lonMax: 138.3, scale: 5, name: '長野市周辺'),
    // 富士山麓
    _BortleRegion(latMin: 35.2, latMax: 35.5, lonMin: 138.5, lonMax: 138.9, scale: 3, name: '富士山麓'),
    // 沖縄南部
    _BortleRegion(latMin: 26.1, latMax: 26.35, lonMin: 127.6, lonMax: 127.85, scale: 6, name: '那覇周辺'),
    // 沖縄北部
    _BortleRegion(latMin: 26.5, latMax: 26.9, lonMin: 127.8, lonMax: 128.3, scale: 3, name: '沖縄北部'),
    // 北海道十勝
    _BortleRegion(latMin: 42.5, latMax: 43.5, lonMin: 143.0, lonMax: 144.5, scale: 2, name: '北海道十勝'),
    // 北海道函館
    _BortleRegion(latMin: 41.7, latMax: 41.85, lonMin: 140.6, lonMax: 140.8, scale: 6, name: '函館市'),
  ];

  int getBortleScale(double latitude, double longitude) {
    for (final region in _regions) {
      if (region.contains(latitude, longitude)) {
        return region.scale;
      }
    }
    // デフォルト: 都市郊外扱い
    return _estimateFromPopulationDensity(latitude, longitude);
  }

  int _estimateFromPopulationDensity(double lat, double lon) {
    // 日本の人口密度パターンから簡易推定
    // 太平洋ベルト地帯（東海道沿い）
    if (lat >= 33.0 && lat <= 36.5 && lon >= 130.0 && lon <= 141.0) {
      return 7;
    }
    // 主要都市圏外の日本
    if (lat >= 30.0 && lat <= 46.0 && lon >= 128.0 && lon <= 146.0) {
      return 5;
    }
    return 4;
  }

  BortleInfo getBortleInfo(int scale) {
    return switch (scale) {
      1 => const BortleInfo(
          scale: 1,
          label: '最暗黒の空',
          description: '天の川が影を作るほど暗い。プロ天文家の観測地レベル。',
          color: 0xFF000033,
          difficultyStars: 1,
        ),
      2 => const BortleInfo(
          scale: 2,
          label: '極めて暗い空',
          description: '天の川が肉眼ではっきり見える。山岳地帯・離島。',
          color: 0xFF000055,
          difficultyStars: 1,
        ),
      3 => const BortleInfo(
          scale: 3,
          label: '農村の空',
          description: '天の川がよく見える。光害の影響が軽微な農村地帯。',
          color: 0xFF001166,
          difficultyStars: 1,
        ),
      4 => const BortleInfo(
          scale: 4,
          label: '農村/郊外の境界',
          description: '地平線付近に光害の影響が見られる。郊外の空。',
          color: 0xFF002288,
          difficultyStars: 2,
        ),
      5 => const BortleInfo(
          scale: 5,
          label: '郊外の空',
          description: '天の川はかすかに見える。住宅地の外縁部。',
          color: 0xFF334499,
          difficultyStars: 2,
        ),
      6 => const BortleInfo(
          scale: 6,
          label: '明るい郊外',
          description: '天の川はほとんど見えない。2等星が限界。',
          color: 0xFF5566AA,
          difficultyStars: 2,
        ),
      7 => const BortleInfo(
          scale: 7,
          label: '郊外/都市の境界',
          description: '光害が強い。明るい星雲・星団のみ見える。',
          color: 0xFF8888BB,
          difficultyStars: 3,
        ),
      8 => const BortleInfo(
          scale: 8,
          label: '都市の空',
          description: '光害で空がオレンジ色。主要な星座のみ識別可能。',
          color: 0xFFBB8844,
          difficultyStars: 3,
        ),
      _ => const BortleInfo(
          scale: 9,
          label: '都市の中心',
          description: '光害が極めて強い。最も明るい星のみ見える。★★★のレア難易度！',
          color: 0xFFCC6633,
          difficultyStars: 3,
        ),
    };
  }

  String getDifficultyLabel(int bortleScale) {
    final info = getBortleInfo(bortleScale);
    final stars = '★' * info.difficultyStars + '☆' * (3 - info.difficultyStars);
    return '$stars (${info.label})';
  }

  // シティ・ライト・チャレンジ: 都市部でのスコアボーナス
  int getCityLightBonus(int bortleScale) {
    if (bortleScale >= 8) return 300; // 都市中心: ★★★ ボーナス
    if (bortleScale >= 6) return 100; // 郊外: ★★ ボーナス
    return 0;
  }
}

class BortleInfo {
  final int scale;
  final String label;
  final String description;
  final int color;
  final int difficultyStars;

  const BortleInfo({
    required this.scale,
    required this.label,
    required this.description,
    required this.color,
    required this.difficultyStars,
  });
}

class _BortleRegion {
  final double latMin;
  final double latMax;
  final double lonMin;
  final double lonMax;
  final int scale;
  final String name;

  const _BortleRegion({
    required this.latMin,
    required this.latMax,
    required this.lonMin,
    required this.lonMax,
    required this.scale,
    required this.name,
  });

  bool contains(double lat, double lon) =>
      lat >= latMin && lat <= latMax && lon >= lonMin && lon <= lonMax;
}
