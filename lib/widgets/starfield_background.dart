import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 本物の星空のような背景ウィジェット。
/// [animate] を true にすると瞬き(twinkling)アニメーションが有効になる。
/// [overlayColor] を指定すると星空の上に半透明のカラーレイヤーを重ねられる。
class StarfieldBackground extends StatefulWidget {
  final Widget? child;
  final bool animate;
  final int seed;
  final int starCount;
  final Color? overlayColor;

  const StarfieldBackground({
    super.key,
    this.child,
    this.animate = false,
    this.seed = 42,
    this.starCount = 420,
    this.overlayColor,
  });

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 深宇宙グラデーション: 真の黒に近いが、中央はわずかに青みがかった暗紺
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF000003),
            Color(0xFF020210),
            Color(0xFF050315),
            Color(0xFF020208),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: widget.animate
                ? AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, __) => CustomPaint(
                      painter: _StarfieldPainter(
                        seed: widget.seed,
                        starCount: widget.starCount,
                        twinklePhase: _ctrl.value,
                      ),
                    ),
                  )
                : CustomPaint(
                    painter: _StarfieldPainter(
                      seed: widget.seed,
                      starCount: widget.starCount,
                      twinklePhase: 0,
                    ),
                  ),
          ),
          // カラーオーバーレイ（ページごとの色味づけ）
          if (widget.overlayColor != null)
            Positioned.fill(
              child: ColoredBox(color: widget.overlayColor!),
            ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Painter
// ─────────────────────────────────────────────────────────
class _StarfieldPainter extends CustomPainter {
  final int seed;
  final int starCount;
  final double twinklePhase;

  const _StarfieldPainter({
    required this.seed,
    required this.starCount,
    required this.twinklePhase,
  });

  // スペクトル型による星の色（O → M 型）
  // 実際の観測と同じく青白が多く、赤は少ない
  static const _spectral = [
    Color(0xFFB8CCFF), // O型  青
    Color(0xFFCCDDFF), // B型  青白
    Color(0xFFDDEEFF), // A型  白青
    Color(0xFFFFFFFF), // A型  純白
    Color(0xFFFFF8F0), // F型  白
    Color(0xFFFFF0D8), // F型  白黄
    Color(0xFFFFE8B8), // G型  黄白（太陽に近い）
    Color(0xFFFFD890), // G型  黄
    Color(0xFFFFBB66), // K型  橙
    Color(0xFFFF9944), // M型  赤橙
  ];

  Color _spectralColor(double t) {
    // t: 0 = most common blue-white, 1 = rare red
    // 青白が約60%, 白系20%, 黄橙系20%の分布に
    if (t < 0.12) return _spectral[0];
    if (t < 0.28) return _spectral[1];
    if (t < 0.42) return _spectral[2];
    if (t < 0.55) return _spectral[3];
    if (t < 0.64) return _spectral[4];
    if (t < 0.72) return _spectral[5];
    if (t < 0.80) return _spectral[6];
    if (t < 0.87) return _spectral[7];
    if (t < 0.94) return _spectral[8];
    return _spectral[9];
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ① 天の川（Milky Way）バンドを先に描画
    _drawMilkyWay(canvas, size);

    // ② 星を描画
    final rng = math.Random(seed);
    for (int i = 0; i < starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;

      // マグニチュード分布: べき乗則で暗い星を多く
      final raw = rng.nextDouble();
      final mag = raw * raw * raw; // cube → 大半が dim、少数が bright

      final colorT = rng.nextDouble();
      final twinkleOff = rng.nextDouble() * math.pi * 2; // 常に消費

      final baseRadius = 0.25 + mag * 2.8;
      final baseAlpha = (0.12 + mag * 0.88).clamp(0.0, 1.0);

      // 瞬き: 明るい星ほど瞬きが目立つ
      final twinkleMod = (mag > 0.45 && twinklePhase > 0)
          ? 0.82 + 0.18 * math.sin(twinklePhase * math.pi * 2 + twinkleOff)
          : 1.0;

      final radius = baseRadius * twinkleMod;
      final alpha = (baseAlpha * twinkleMod * 255).clamp(0, 255).toInt();
      final color = _spectralColor(colorT);

      if (mag > 0.55) {
        // 輝いている星: グロー + コア
        _drawGlowingStar(canvas, Offset(x, y), radius, color, alpha);
      } else {
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()
            ..color = color.withAlpha(alpha)
            ..style = PaintingStyle.fill,
        );
      }
    }

    // ③ 超明るい「固定星」（回折スパイク付き）
    _drawLandmarkStar(
        canvas, Offset(size.width * 0.15, size.height * 0.14),
        const Color(0xFFAABBFF), 3.2, twinklePhase, 0.0);
    _drawLandmarkStar(
        canvas, Offset(size.width * 0.78, size.height * 0.09),
        const Color(0xFFFFFFFF), 2.8, twinklePhase, 1.1);
    _drawLandmarkStar(
        canvas, Offset(size.width * 0.52, size.height * 0.88),
        const Color(0xFFFFCC88), 2.6, twinklePhase, 2.3);
    _drawLandmarkStar(
        canvas, Offset(size.width * 0.33, size.height * 0.65),
        const Color(0xFFCCDDFF), 2.2, twinklePhase, 3.7);
    _drawLandmarkStar(
        canvas, Offset(size.width * 0.88, size.height * 0.55),
        const Color(0xFFFFE8AA), 2.0, twinklePhase, 0.8);
  }

  // ── 天の川 ──
  void _drawMilkyWay(Canvas canvas, Size size) {
    // 薄い帯状の光（左上→右下）
    final bandPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 55);

    // 外側の広い帯
    final outer = Path()
      ..moveTo(-30, size.height * 0.05)
      ..lineTo(size.width + 30, size.height * 0.52)
      ..lineTo(size.width + 30, size.height * 0.72)
      ..lineTo(-30, size.height * 0.28)
      ..close();
    bandPaint.color = const Color(0x0A99AACC);
    canvas.drawPath(outer, bandPaint);

    // 内側の明るいコア
    final inner = Path()
      ..moveTo(-10, size.height * 0.12)
      ..lineTo(size.width + 10, size.height * 0.56)
      ..lineTo(size.width + 10, size.height * 0.64)
      ..lineTo(-10, size.height * 0.20)
      ..close();
    bandPaint
      ..color = const Color(0x0CAABBDD)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawPath(inner, bandPaint);

    // 天の川に乗る極小星（数を増やして濃密感）
    final mwRng = math.Random(seed ^ 0xABCD1234);
    for (int i = 0; i < 200; i++) {
      final t = mwRng.nextDouble();
      final bx = t * size.width;
      // 帯の中心ライン: y = 0.16 + t*0.48 → 散布幅±15%
      final bandCenter = size.height * (0.16 + t * 0.48);
      final scatter = (mwRng.nextDouble() - 0.5) * size.height * 0.14;
      final by = bandCenter + scatter;
      if (by < 0 || by > size.height) continue;

      final dim = mwRng.nextDouble() * 0.22 + 0.04;
      canvas.drawCircle(
        Offset(bx, by),
        mwRng.nextDouble() * 0.55 + 0.1,
        Paint()
          ..color = Color.fromARGB((dim * 200).toInt(), 180, 200, 255)
          ..style = PaintingStyle.fill,
      );
    }
  }

  // ── グロー付き星（中程度以上の明るさ） ──
  void _drawGlowingStar(
      Canvas canvas, Offset pos, double radius, Color color, int alpha) {
    // 外グロー（広くて薄い）
    canvas.drawCircle(
      pos,
      radius * 5,
      Paint()
        ..color = color.withAlpha((alpha * 0.04).toInt())
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 2.5),
    );
    // 中グロー
    canvas.drawCircle(
      pos,
      radius * 2.5,
      Paint()
        ..color = color.withAlpha((alpha * 0.18).toInt())
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 1.2),
    );
    // コア
    canvas.drawCircle(
      pos,
      radius,
      Paint()
        ..color = color.withAlpha(alpha)
        ..style = PaintingStyle.fill,
    );
  }

  // ── 超明るい固定星（回折スパイク付き） ──
  void _drawLandmarkStar(Canvas canvas, Offset pos, Color color,
      double baseRadius, double twinklePhase, double phaseOff) {
    final mod = twinklePhase > 0
        ? 0.88 + 0.12 * math.sin(twinklePhase * math.pi * 2 + phaseOff)
        : 1.0;
    final r = baseRadius * mod;

    // 大外グロー
    canvas.drawCircle(pos, r * 10,
        Paint()
          ..color = color.withAlpha(10)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 5));
    // 中グロー
    canvas.drawCircle(pos, r * 5,
        Paint()
          ..color = color.withAlpha(28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 2));
    // 内グロー
    canvas.drawCircle(pos, r * 2.5,
        Paint()
          ..color = color.withAlpha(70)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
    // コア
    canvas.drawCircle(pos, r,
        Paint()
          ..color = color.withAlpha(255)
          ..style = PaintingStyle.fill);

    // 回折スパイク（×字）
    final spikePaint = Paint()
      ..strokeWidth = 0.7
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.8);
    final spikeLen = r * 14;
    final spikeAlpha = (80 * mod).toInt();

    for (final angle in [0.0, math.pi / 2, math.pi / 4, -math.pi / 4]) {
      final dx = math.cos(angle) * spikeLen;
      final dy = math.sin(angle) * spikeLen;
      spikePaint.color = color.withAlpha(spikeAlpha);
      canvas.drawLine(
          Offset(pos.dx - dx, pos.dy - dy),
          Offset(pos.dx + dx, pos.dy + dy),
          spikePaint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) =>
      old.twinklePhase != twinklePhase ||
      old.seed != seed ||
      old.starCount != starCount;
}
