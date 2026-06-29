import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/constellation_provider.dart';
import '../providers/settings_provider.dart';
import '../models/constellation.dart';
import '../services/bortle_service.dart';
import '../services/constellation_art.dart';

// シミュレーション用のスキャン状態
enum ScanState { idle, scanning, detected, confirmed }

final _scanStateProvider = StateProvider<ScanState>((ref) => ScanState.idle);
final _scanProgressProvider = StateProvider<double>((ref) => 0.0);
final _detectedConstellationProvider =
    StateProvider<Constellation?>((ref) => null);
final _simulatedBortleProvider = StateProvider<int>((ref) => 8);

class ARObservationScreen extends ConsumerStatefulWidget {
  const ARObservationScreen({super.key});

  @override
  ConsumerState<ARObservationScreen> createState() =>
      _ARObservationScreenState();
}

class _ARObservationScreenState extends ConsumerState<ARObservationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _startScan(List<Constellation> constellations) {
    if (ref.read(_scanStateProvider) != ScanState.idle) return;

    ref.read(_scanStateProvider.notifier).state = ScanState.scanning;
    ref.read(_scanProgressProvider.notifier).state = 0.0;

    _scanController.reset();

    // 3秒かけてスキャン → 解放済み星座からランダムに検出
    _scanController.animateTo(1.0, duration: const Duration(seconds: 3)).then(
      (_) {
        if (!mounted) return;
        final rng = math.Random();
        final unlockedIds = ref.read(unlockedIdsProvider);
        final available = constellations
            .where((c) => unlockedIds.contains(c.id))
            .toList();
        final pool = available.isEmpty
            ? constellations.where((c) => c.category == 'zodiac').toList()
            : available;
        final detected = pool[rng.nextInt(pool.length)];
        ref.read(_detectedConstellationProvider.notifier).state = detected;
        ref.read(_scanStateProvider.notifier).state = ScanState.detected;

        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ref.read(_scanStateProvider.notifier).state = ScanState.confirmed;
        });
      },
    );

    _scanController.addListener(() {
      if (!mounted) return;
      ref.read(_scanProgressProvider.notifier).state = _scanController.value;
    });
  }

  void _reset() {
    ref.read(_scanStateProvider.notifier).state = ScanState.idle;
    ref.read(_scanProgressProvider.notifier).state = 0.0;
    ref.read(_detectedConstellationProvider.notifier).state = null;
    _scanController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(_scanStateProvider);
    final isNightMode = ref.watch(nightModeProvider);
    final bortle = ref.watch(_simulatedBortleProvider);
    final bortleInfo = BortleService.instance.getBortleInfo(bortle);
    final constellationsAsync = ref.watch(constellationListProvider);

    return constellationsAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (constellations) => Scaffold(
        body: _NightModeWrapper(
          enabled: isNightMode,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Simulated sky background
              _SimulatedSkyBackground(bortle: bortle),

              // Star overlay + constellation lines
              if (scanState == ScanState.confirmed)
                _ConstellationOverlay(
                  constellation:
                      ref.watch(_detectedConstellationProvider),
                ),

              // Scanning reticle
              Center(
                child: _ScanReticle(
                  scanState: scanState,
                  progress: ref.watch(_scanProgressProvider),
                  pulseAnim: _pulseAnim,
                ),
              ),

              // Top HUD
              SafeArea(
                child: _TopHUD(
                  bortle: bortle,
                  bortleInfo: bortleInfo,
                ),
              ),

              // Detected constellation panel
              if (scanState == ScanState.confirmed)
                Positioned(
                  bottom: 120,
                  left: 16,
                  right: 16,
                  child: _DetectedPanel(
                    constellation: ref.watch(_detectedConstellationProvider),
                    bortle: bortle,
                  ),
                ),

              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: _BottomControls(
                    scanState: scanState,
                    onScan: () => _startScan(constellations),
                    onReset: _reset,
                    onRecord: () {
                      final detected = ref.read(_detectedConstellationProvider);
                      if (detected != null) {
                        context.push('/add-observation/${detected.id}/$bortle');
                      }
                    },
                  ),
                ),
              ),

              // Night mode toggle
              Positioned(
                top: 80,
                right: 16,
                child: SafeArea(
                  child: _NightModeToggle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NightModeWrapper extends StatelessWidget {
  final bool enabled;
  final Widget child;
  const _NightModeWrapper({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        0.3, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: child,
    );
  }
}

class _SimulatedSkyBackground extends StatelessWidget {
  final int bortle;
  const _SimulatedSkyBackground({required this.bortle});

  @override
  Widget build(BuildContext context) {
    // 明るさに応じた背景色
    final brightness = (bortle / 9.0).clamp(0.0, 1.0);
    final topColor = Color.lerp(
      const Color(0xFF000010),
      const Color(0xFF1a0a00),
      brightness,
    )!;
    final bottomColor = Color.lerp(
      const Color(0xFF000533),
      const Color(0xFF331500),
      brightness,
    )!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
      ),
      child: CustomPaint(
        painter: _StarfieldPainter(bortle: bortle),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final int bortle;
  _StarfieldPainter({required this.bortle});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // 固定シードで一貫した星パターン
    final starCount = (500 * (10 - bortle) / 9).toInt();
    final maxBrightness = (1.0 - bortle / 12.0).clamp(0.1, 1.0);

    for (int i = 0; i < starCount; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final brightness = (rng.nextDouble() * maxBrightness).clamp(0.05, 1.0);
      final radius = rng.nextDouble() * 1.5 + 0.3;

      final paint = Paint()
        ..color = Colors.white.withAlpha((brightness * 255).toInt())
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) =>
      oldDelegate.bortle != bortle;
}

class _ConstellationOverlay extends StatefulWidget {
  final Constellation? constellation;
  const _ConstellationOverlay({required this.constellation});

  @override
  State<_ConstellationOverlay> createState() => _ConstellationOverlayState();
}

class _ConstellationOverlayState extends State<_ConstellationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.constellation == null) return const SizedBox.shrink();
    final art = constellationArts[widget.constellation!.id];

    return FadeTransition(
      opacity: _fade,
      child: Positioned.fill(
        child: Stack(
          children: [
            // 星座ラインアート（データがある場合）
            if (art != null)
              Padding(
                padding: const EdgeInsets.all(40),
                child: CustomPaint(
                  painter: ConstellationLinePainter(
                    art: art,
                    starColor: Colors.lightBlue.shade100,
                    lineColor: const Color(0x99AADDFF),
                    starRadius: 3.5,
                  ),
                ),
              ),
            // 絵文字ラベル（中央下寄り）
            Align(
              alignment: const Alignment(0, 0.5),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.constellation!.emoji,
                  style: art != null
                      ? const TextStyle(fontSize: 40)
                      : const TextStyle(fontSize: 100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanReticle extends StatelessWidget {
  final ScanState scanState;
  final double progress;
  final Animation<double> pulseAnim;

  const _ScanReticle({
    required this.scanState,
    required this.progress,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    if (scanState == ScanState.confirmed) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Transform.scale(
          scale: scanState == ScanState.idle ? pulseAnim.value : 1.0,
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _ReticlePainter(
                progress: progress,
                isScanning: scanState == ScanState.scanning,
                isDetected: scanState == ScanState.detected,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReticlePainter extends CustomPainter {
  final double progress;
  final bool isScanning;
  final bool isDetected;

  _ReticlePainter({
    required this.progress,
    required this.isScanning,
    required this.isDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Outer circle
    final circlePaint = Paint()
      ..color = isDetected
          ? Colors.green
          : isScanning
              ? Colors.amber
              : Colors.white.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, circlePaint);

    // Crosshairs
    final linePaint = Paint()
      ..color = circlePaint.color.withAlpha(100)
      ..strokeWidth = 1;

    canvas.drawLine(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx - radius + 20, center.dy),
        linePaint);
    canvas.drawLine(
        Offset(center.dx + radius - 20, center.dy),
        Offset(center.dx + radius, center.dy),
        linePaint);
    canvas.drawLine(
        Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy - radius + 20),
        linePaint);
    canvas.drawLine(
        Offset(center.dx, center.dy + radius - 20),
        Offset(center.dx, center.dy + radius),
        linePaint);

    // Progress arc
    if (isScanning) {
      final progressPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }

    // Corner brackets
    _drawCornerBracket(canvas, center, radius, 1, 1, linePaint);
    _drawCornerBracket(canvas, center, radius, -1, 1, linePaint);
    _drawCornerBracket(canvas, center, radius, 1, -1, linePaint);
    _drawCornerBracket(canvas, center, radius, -1, -1, linePaint);
  }

  void _drawCornerBracket(Canvas canvas, Offset center, double radius,
      double sx, double sy, Paint paint) {
    const bracketSize = 16.0;
    const offset = 0.7071; // cos(45°)
    final bx = center.dx + sx * radius * offset;
    final by = center.dy + sy * radius * offset;
    canvas.drawLine(
        Offset(bx, by), Offset(bx + sx * bracketSize, by), paint);
    canvas.drawLine(
        Offset(bx, by), Offset(bx, by + sy * bracketSize), paint);
  }

  @override
  bool shouldRepaint(_ReticlePainter old) =>
      old.progress != progress ||
      old.isScanning != isScanning ||
      old.isDetected != isDetected;
}

class _TopHUD extends ConsumerWidget {
  final int bortle;
  final BortleInfo bortleInfo;

  const _TopHUD({required this.bortle, required this.bortleInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Location & Bortle
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '位置情報なし（シミュレーション）',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Bortle badge
          GestureDetector(
            onTap: () => _showBortleInfo(context, bortle, bortleInfo),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(bortleInfo.color).withAlpha(200),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bortle $bortle',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '★' * bortleInfo.difficultyStars,
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBortleInfo(BuildContext context, int bortle, BortleInfo info) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'シティ・ライト・チャレンジ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bortleスケール: $bortle / 9',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              info.label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              info.description,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              '難易度: ${'★' * info.difficultyStars}${'☆' * (3 - info.difficultyStars)}',
              style: const TextStyle(color: Colors.amber, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              bortle >= 7
                  ? '都市部での観測はレア！高難易度クリアで称号獲得のチャンス 🏆'
                  : '暗い空での観測はたくさんの星が見えて有利！',
              style: TextStyle(
                color: bortle >= 7 ? Colors.amber : Colors.greenAccent,
                fontSize: 12,
              ),
            ),
            // Bortle slider (simulation)
            const SizedBox(height: 16),
            Text(
              'シミュレーション: Bortleスケールを変更',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            Consumer(builder: (ctx, ref, _) {
              final b = ref.watch(_simulatedBortleProvider);
              return Slider(
                value: b.toDouble(),
                min: 1,
                max: 9,
                divisions: 8,
                label: 'Bortle $b',
                activeColor: Colors.amber,
                onChanged: (v) {
                  ref.read(_simulatedBortleProvider.notifier).state =
                      v.round();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DetectedPanel extends StatelessWidget {
  final Constellation? constellation;
  final int bortle;

  const _DetectedPanel({required this.constellation, required this.bortle});

  @override
  Widget build(BuildContext context) {
    if (constellation == null) return const SizedBox.shrink();
    final bortleInfo = BortleService.instance.getBortleInfo(bortle);
    final diffStr =
        '★' * bortleInfo.difficultyStars + '☆' * (3 - bortleInfo.difficultyStars);

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.withAlpha(120)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(constellation!.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '星座を発見！',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        constellation!.nameJa,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        constellation!.nameEn,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(bortleInfo.color).withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Bortle $bortle  $diffStr',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (bortle >= 7)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '🏆 都市難易度クリア！',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final ScanState scanState;
  final VoidCallback onScan;
  final VoidCallback onReset;
  final VoidCallback onRecord;

  const _BottomControls({
    required this.scanState,
    required this.onScan,
    required this.onReset,
    required this.onRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withAlpha(200)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scanState == ScanState.idle) ...[
            _CircleButton(
              icon: Icons.my_location,
              label: 'スキャン開始',
              onTap: onScan,
              color: Colors.white,
              size: 70,
            ),
          ] else if (scanState == ScanState.scanning) ...[
            _CircleButton(
              icon: Icons.radar,
              label: 'スキャン中...',
              onTap: () {},
              color: Colors.amber,
              size: 70,
            ),
          ] else if (scanState == ScanState.confirmed) ...[
            _CircleButton(
              icon: Icons.refresh,
              label: 'やり直す',
              onTap: onReset,
              color: Colors.white70,
              size: 56,
            ),
            const SizedBox(width: 32),
            _CircleButton(
              icon: Icons.camera_alt,
              label: '記録する',
              onTap: onRecord,
              color: Colors.amber,
              size: 70,
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _CircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              color: color.withAlpha(40),
            ),
            child: Icon(icon, color: color, size: size * 0.45),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _NightModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNight = ref.watch(nightModeProvider);
    return GestureDetector(
      onTap: () => ref
          .read(settingsProvider.notifier)
          .setNightMode(!isNight),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isNight
              ? Colors.red.shade900.withAlpha(200)
              : Colors.black.withAlpha(120),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isNight ? Colors.red.shade700 : Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.remove_red_eye,
              color: isNight ? Colors.red.shade300 : Colors.white60,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              isNight ? '赤色 ON' : '赤色 OFF',
              style: TextStyle(
                color: isNight ? Colors.red.shade300 : Colors.white60,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
