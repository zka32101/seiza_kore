import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/constellation.dart';
import 'starfield_background.dart';

/// 星座解放時の全画面セレブレーション。
/// [showUnlockCelebration] を呼ぶことで表示する。
Future<void> showUnlockCelebration(
  BuildContext context, {
  required Constellation constellation,
  VoidCallback? onViewDetail,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '閉じる',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => _CelebrationPage(
      constellation: constellation,
      onViewDetail: onViewDetail,
    ),
    transitionBuilder: (_, anim, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

// ──────────────────────────────────────────────────────────
class _CelebrationPage extends StatefulWidget {
  final Constellation constellation;
  final VoidCallback? onViewDetail;
  const _CelebrationPage({required this.constellation, this.onViewDetail});

  @override
  State<_CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<_CelebrationPage>
    with TickerProviderStateMixin {
  late AnimationController _particleCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _emojiScale;
  late Animation<double> _titleFade;
  late Animation<double> _buttonFade;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _emojiScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentCtrl,
        curve: const Interval(0.60, 1.00, curve: Curves.easeOut),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _particleCtrl, curve: Curves.easeInOut),
    );

    // パーティクルが半分終わったらコンテンツ開始
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: StarfieldBackground(
        animate: true,
        seed: widget.constellation.id.hashCode.abs() % 500,
        starCount: 350,
        child: Stack(
          children: [
            // パーティクルバースト
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _BurstPainter(
                    progress: _particleCtrl.value,
                    seed: widget.constellation.id.hashCode,
                  ),
                ),
              ),
            ),

            // 閉じるボタン（右上）
            Positioned(
              top: 52,
              right: 20,
              child: SafeArea(
                child: FadeTransition(
                  opacity: _buttonFade,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),

            // メインコンテンツ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "新発見！" ラベル
                  FadeTransition(
                    opacity: _titleFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.amber.withAlpha(120), width: 1),
                      ),
                      child: const Text(
                        '✨  新しい星座を発見！  ✨',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 絵文字（グロー付き）
                  AnimatedBuilder(
                    animation: _contentCtrl,
                    builder: (_, __) => ScaleTransition(
                      scale: _emojiScale,
                      child: AnimatedBuilder(
                        animation: _particleCtrl,
                        builder: (_, __) => Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber
                                    .withAlpha((100 * _glowPulse.value).toInt()),
                                blurRadius: 60 * _glowPulse.value,
                                spreadRadius: 12 * _glowPulse.value,
                              ),
                              BoxShadow(
                                color: Colors.white
                                    .withAlpha((40 * _glowPulse.value).toInt()),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.constellation.emoji,
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 星座名
                  FadeTransition(
                    opacity: _titleFade,
                    child: Column(
                      children: [
                        Text(
                          widget.constellation.nameJa,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(blurRadius: 20, color: Colors.black87)
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.constellation.nameEn,
                          style: TextStyle(
                            color: Colors.white.withAlpha(140),
                            fontSize: 15,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 難易度バッジ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (i) => Icon(
                              i < widget.constellation.baseDifficulty
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber.shade400,
                              size: 18,
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ボタン
                  FadeTransition(
                    opacity: _buttonFade,
                    child: Column(
                      children: [
                        // 詳細を見る
                        SizedBox(
                          width: 220,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onViewDetail?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 8,
                              shadowColor: Colors.amber.withAlpha(100),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_stories, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  '図鑑で見る',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            '閉じる',
                            style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  パーティクルバースト（星が中心から外側に飛び出る）
// ──────────────────────────────────────────────────────────
class _BurstPainter extends CustomPainter {
  final double progress; // 0 → 1
  final int seed;

  static const _particleCount = 60;

  _BurstPainter({required this.progress, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < _particleCount; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final maxDist = size.width * 0.55 * speed;
      final delay = rng.nextDouble() * 0.3;
      final t = ((progress - delay) / (1.0 - delay)).clamp(0.0, 1.0);

      if (t <= 0) continue;

      // easeOut で減速
      final easedT = 1 - math.pow(1 - t, 3).toDouble();
      final dist = maxDist * easedT;

      final x = cx + math.cos(angle) * dist;
      final y = cy + math.sin(angle) * dist;

      // フェードアウト（後半で消える）
      final alpha = t < 0.6 ? 1.0 : 1.0 - (t - 0.6) / 0.4;
      final radius = (0.8 + rng.nextDouble() * 2.0) * (1.0 - easedT * 0.3);

      // 星の色（スペクトル）
      final colorChoice = rng.nextDouble();
      final Color starColor;
      if (colorChoice < 0.3) {
        starColor = Colors.amber;
      } else if (colorChoice < 0.55) {
        starColor = Colors.white;
      } else if (colorChoice < 0.75) {
        starColor = const Color(0xFFAABBFF);
      } else if (colorChoice < 0.88) {
        starColor = Colors.amber.shade200;
      } else {
        starColor = const Color(0xFFFFCCAA);
      }

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = starColor.withAlpha((alpha * 230).toInt())
          ..style = PaintingStyle.fill,
      );

      // 明るいパーティクルはグロー付き
      if (radius > 1.5) {
        canvas.drawCircle(
          Offset(x, y),
          radius * 3,
          Paint()
            ..color = starColor.withAlpha((alpha * 40).toInt())
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }

    // 中心のフラッシュ（最初の瞬間）
    if (progress < 0.35) {
      final flashAlpha = (1.0 - progress / 0.35) * 0.6;
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.5 * (progress / 0.35),
        Paint()
          ..color = Colors.amber.withAlpha((flashAlpha * 60).toInt())
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}
