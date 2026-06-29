import 'package:flutter/material.dart';

// 星座アートデータ：各星の正規化座標(0〜1)と線のエッジリスト
class ConstellationArt {
  final List<Offset> stars;   // 0〜1 の正規化座標
  final List<List<int>> lines; // stars インデックスのペアリスト

  const ConstellationArt({required this.stars, required this.lines});
}

// 黄道12星座 + 主要北天星座のアートデータ
const Map<String, ConstellationArt> constellationArts = {
  'aries': ConstellationArt(
    stars: [Offset(0.3, 0.4), Offset(0.5, 0.45), Offset(0.7, 0.5), Offset(0.85, 0.35)],
    lines: [[0,1],[1,2],[2,3]],
  ),
  'taurus': ConstellationArt(
    stars: [
      Offset(0.5, 0.5),  // アルデバラン
      Offset(0.35, 0.4), Offset(0.25, 0.35), Offset(0.4, 0.3), Offset(0.6, 0.35),
      Offset(0.7, 0.2), Offset(0.75, 0.3),
    ],
    lines: [[0,1],[1,2],[0,3],[0,4],[4,5],[5,6],[4,6]],
  ),
  'gemini': ConstellationArt(
    stars: [
      Offset(0.25, 0.15), Offset(0.75, 0.15), // カストル、ポルックス
      Offset(0.2, 0.35), Offset(0.7, 0.35),
      Offset(0.2, 0.55), Offset(0.7, 0.55),
      Offset(0.25, 0.75), Offset(0.5, 0.8), Offset(0.75, 0.75),
    ],
    lines: [[0,2],[2,4],[4,6],[6,7],[7,8],[8,5],[5,3],[3,1],[1,0]],
  ),
  'cancer': ConstellationArt(
    stars: [
      Offset(0.5, 0.5),   // プレセペ（中心）
      Offset(0.2, 0.25), Offset(0.8, 0.25),
      Offset(0.2, 0.75), Offset(0.8, 0.75),
    ],
    lines: [[1,0],[2,0],[3,0],[4,0]],
  ),
  'leo': ConstellationArt(
    stars: [
      Offset(0.5, 0.3),   // レグルス
      Offset(0.4, 0.4), Offset(0.55, 0.45), Offset(0.7, 0.4),
      Offset(0.7, 0.25), Offset(0.6, 0.2), Offset(0.45, 0.2),
      Offset(0.85, 0.5),  // デネボラ
    ],
    lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,0],[3,7]],
  ),
  'virgo': ConstellationArt(
    stars: [
      Offset(0.7, 0.55), // スピカ
      Offset(0.6, 0.4), Offset(0.45, 0.35),
      Offset(0.35, 0.45), Offset(0.2, 0.4),
      Offset(0.55, 0.25), Offset(0.75, 0.3), Offset(0.85, 0.4),
    ],
    lines: [[0,1],[1,2],[2,3],[3,4],[2,5],[5,6],[6,7],[1,7]],
  ),
  'libra': ConstellationArt(
    stars: [
      Offset(0.5, 0.65), // 中心
      Offset(0.2, 0.5), Offset(0.8, 0.5),
      Offset(0.35, 0.3), Offset(0.65, 0.3),
    ],
    lines: [[0,1],[0,2],[1,3],[2,4],[3,4]],
  ),
  'scorpius': ConstellationArt(
    stars: [
      Offset(0.5, 0.25),  // アンタレス
      Offset(0.35, 0.2), Offset(0.2, 0.25), Offset(0.1, 0.35),
      Offset(0.55, 0.35), Offset(0.6, 0.45), Offset(0.65, 0.55),
      Offset(0.7, 0.65), Offset(0.75, 0.75), Offset(0.65, 0.85), Offset(0.55, 0.88),
    ],
    lines: [[3,2],[2,1],[1,0],[0,4],[4,5],[5,6],[6,7],[7,8],[8,9],[9,10]],
  ),
  'sagittarius': ConstellationArt(
    stars: [
      Offset(0.5, 0.5), Offset(0.35, 0.55), Offset(0.25, 0.45),
      Offset(0.3, 0.35), Offset(0.45, 0.3), Offset(0.6, 0.35),
      Offset(0.65, 0.5), Offset(0.6, 0.65), Offset(0.45, 0.7),
    ],
    lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,0],[0,7],[7,8],[8,1]],
  ),
  'capricornus': ConstellationArt(
    stars: [
      Offset(0.15, 0.35), Offset(0.3, 0.25), Offset(0.5, 0.2),
      Offset(0.7, 0.3), Offset(0.8, 0.45),
      Offset(0.7, 0.65), Offset(0.5, 0.75), Offset(0.3, 0.7),
      Offset(0.15, 0.55),
    ],
    lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,0]],
  ),
  'aquarius': ConstellationArt(
    stars: [
      Offset(0.4, 0.3),  // サダルスード
      Offset(0.25, 0.35), Offset(0.5, 0.4), Offset(0.6, 0.3),
      Offset(0.5, 0.55), Offset(0.35, 0.65), Offset(0.6, 0.65),
      Offset(0.45, 0.8),
    ],
    lines: [[0,1],[0,2],[2,3],[0,4],[4,5],[4,6],[5,7],[6,7]],
  ),
  'pisces': ConstellationArt(
    stars: [
      Offset(0.5, 0.5),  // 結び目
      Offset(0.2, 0.35), Offset(0.1, 0.5), Offset(0.2, 0.65),
      Offset(0.35, 0.55),
      Offset(0.65, 0.4), Offset(0.8, 0.3), Offset(0.85, 0.5), Offset(0.75, 0.65),
      Offset(0.6, 0.6),
    ],
    lines: [[1,2],[2,3],[3,4],[4,0],[0,9],[9,8],[8,7],[7,6],[6,5],[5,0]],
  ),
  'orion': ConstellationArt(
    stars: [
      Offset(0.25, 0.15), // ベテルギウス
      Offset(0.75, 0.2),  // ベラトリクス
      Offset(0.3, 0.45),  // 三つ星左
      Offset(0.5, 0.45),  // 三つ星中
      Offset(0.7, 0.45),  // 三つ星右
      Offset(0.2, 0.75),  // リゲル近く
      Offset(0.8, 0.8),   // リゲル
      Offset(0.5, 0.7),   // 中央下
    ],
    lines: [[0,1],[0,2],[1,4],[2,3],[3,4],[2,5],[4,6],[5,7],[7,6],[3,7]],
  ),
  'ursa_major': ConstellationArt(
    stars: [
      Offset(0.1, 0.7),   // ドゥーベ
      Offset(0.25, 0.75), // メラク
      Offset(0.4, 0.65),  // フェクダ
      Offset(0.5, 0.55),  // メグレズ
      Offset(0.6, 0.4),   // アリオト
      Offset(0.75, 0.3),  // ミザール
      Offset(0.9, 0.2),   // アルカイド（柄の先）
    ],
    lines: [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6]],
  ),
  'cassiopeia': ConstellationArt(
    stars: [
      Offset(0.1, 0.6),
      Offset(0.3, 0.3),
      Offset(0.5, 0.5),
      Offset(0.7, 0.25),
      Offset(0.9, 0.5),
    ],
    lines: [[0,1],[1,2],[2,3],[3,4]],
  ),
  'cygnus': ConstellationArt(
    stars: [
      Offset(0.5, 0.1),  // デネブ
      Offset(0.5, 0.4),
      Offset(0.5, 0.7),  // 十字の縦
      Offset(0.5, 0.9),
      Offset(0.2, 0.4),  // 十字の横左
      Offset(0.8, 0.4),  // 十字の横右
    ],
    lines: [[0,1],[1,2],[2,3],[4,1],[1,5]],
  ),
  'lyra': ConstellationArt(
    stars: [
      Offset(0.5, 0.15), // ベガ
      Offset(0.3, 0.5),
      Offset(0.45, 0.7),
      Offset(0.55, 0.7),
      Offset(0.7, 0.5),
    ],
    lines: [[0,1],[0,4],[1,2],[2,3],[3,4],[1,4]],
  ),
  'leo_minor': ConstellationArt(
    stars: [Offset(0.3, 0.5), Offset(0.5, 0.4), Offset(0.7, 0.5), Offset(0.5, 0.65)],
    lines: [[0,1],[1,2],[2,3],[3,0]],
  ),
};

// 星座アートを描画する CustomPainter
class ConstellationLinePainter extends CustomPainter {
  final ConstellationArt art;
  final Color starColor;
  final Color lineColor;
  final double starRadius;

  const ConstellationLinePainter({
    required this.art,
    this.starColor = Colors.white,
    this.lineColor = const Color(0x99AAAAFF),
    this.starRadius = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final starPaint = Paint()
      ..color = starColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = starColor.withAlpha(60)
      ..style = PaintingStyle.fill;

    // 座標変換
    Offset toPos(Offset normalized) =>
        Offset(normalized.dx * size.width, normalized.dy * size.height);

    // 線を描く
    for (final edge in art.lines) {
      if (edge.length < 2) continue;
      canvas.drawLine(toPos(art.stars[edge[0]]), toPos(art.stars[edge[1]]), linePaint);
    }

    // 星を描く
    for (final s in art.stars) {
      final pos = toPos(s);
      // グロー
      canvas.drawCircle(pos, starRadius * 2.5, glowPaint);
      // 本体
      canvas.drawCircle(pos, starRadius, starPaint);
    }
  }

  @override
  bool shouldRepaint(ConstellationLinePainter old) =>
      old.art != art || old.starColor != starColor;
}
