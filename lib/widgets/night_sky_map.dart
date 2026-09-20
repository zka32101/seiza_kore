import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/constellation.dart';
import '../services/sky_position_service.dart';
import '../l10n/generated/app_localizations.dart';

/// 星図上に配置された1つの星座（描画・タップ判定用）
class PlottedConstellation {
  final Constellation constellation;
  final HorizontalPosition position;

  const PlottedConstellation({
    required this.constellation,
    required this.position,
  });
}

/// 円形の全天星図（プラネタリウム投影）。
/// 中心=天頂、外周=地平線。方位角0°=北を上に、東を右に配置する
/// （地面に寝転んで夜空を見上げたときの向き）。
class NightSkyMap extends StatelessWidget {
  final List<PlottedConstellation> constellations;
  final HorizontalPosition? moonPosition;
  final HorizontalPosition? sunPosition;
  final String moonEmoji;
  final bool isDaytime;
  final void Function(Constellation)? onConstellationTap;

  /// 表示言語コード（'ja' または 'en'）。
  /// 省略時は日本語をデフォルトとし、既存の呼び出し元（BuildContextを
  /// 渡さない/更新しない呼び出し元）との後方互換性を保つ。
  final String languageCode;

  const NightSkyMap({
    super.key,
    required this.constellations,
    this.moonPosition,
    this.sunPosition,
    this.moonEmoji = '🌕',
    this.isDaytime = false,
    this.onConstellationTap,
    this.languageCode = 'ja',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final directionLabels = <String, double>{
      l10n.nightSkyMapNorth: 0.0,
      l10n.nightSkyMapEast: 90.0,
      l10n.nightSkyMapSouth: 180.0,
      l10n.nightSkyMapWest: 270.0,
    };
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, size),
            child: CustomPaint(
              size: size,
              painter: _NightSkyPainter(
                constellations: constellations,
                moonPosition: moonPosition,
                sunPosition: sunPosition,
                moonEmoji: moonEmoji,
                isDaytime: isDaytime,
                languageCode: languageCode,
                directionLabels: directionLabels,
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset local, Size size) {
    if (onConstellationTap == null) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 24;

    PlottedConstellation? closest;
    double closestDist = double.infinity;
    for (final pc in constellations) {
      if (!pc.position.isVisible) continue;
      final p = _project(pc.position, center, maxRadius);
      final dist = (p - local).distance;
      if (dist < closestDist) {
        closestDist = dist;
        closest = pc;
      }
    }
    if (closest != null && closestDist < 28) {
      onConstellationTap!(closest.constellation);
    }
  }

  static Offset _project(HorizontalPosition pos, Offset center, double maxRadius) {
    final r = maxRadius * (90 - pos.altitude) / 90;
    final azRad = pos.azimuth * math.pi / 180.0;
    final dx = r * math.sin(azRad);
    final dy = -r * math.cos(azRad);
    return Offset(center.dx + dx, center.dy + dy);
  }
}

class _NightSkyPainter extends CustomPainter {
  final List<PlottedConstellation> constellations;
  final HorizontalPosition? moonPosition;
  final HorizontalPosition? sunPosition;
  final String moonEmoji;
  final bool isDaytime;
  final String languageCode;
  final Map<String, double> directionLabels;

  _NightSkyPainter({
    required this.constellations,
    required this.moonPosition,
    required this.sunPosition,
    required this.moonEmoji,
    required this.isDaytime,
    required this.languageCode,
    required this.directionLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - 24;

    _drawBackground(canvas, center, maxRadius);
    _drawAltitudeRings(canvas, center, maxRadius);
    _drawDirectionLabels(canvas, center, maxRadius);

    for (final pc in constellations) {
      if (!pc.position.isVisible) continue;
      _drawConstellation(canvas, pc, center, maxRadius);
    }

    if (sunPosition != null && sunPosition!.isVisible) {
      _drawBody(canvas, sunPosition!, center, maxRadius, '☀️', 22);
    }
    if (moonPosition != null && moonPosition!.isVisible) {
      _drawBody(canvas, moonPosition!, center, maxRadius, moonEmoji, 22);
    }
  }

  void _drawBackground(Canvas canvas, Offset center, double r) {
    final bgColors = isDaytime
        ? [const Color(0xFF4A7FC1), const Color(0xFF87B8E0)]
        : [const Color(0xFF050818), const Color(0xFF141B3D)];
    final paint = Paint()
      ..shader = RadialGradient(colors: bgColors)
          .createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);

    final border = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, r, border);
  }

  void _drawAltitudeRings(Canvas canvas, Offset center, double maxR) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final alt in [30, 60]) {
      final ringR = maxR * (90 - alt) / 90;
      canvas.drawCircle(center, ringR, paint);
    }
  }

  void _drawDirectionLabels(Canvas canvas, Offset center, double maxR) {
    directionLabels.forEach((label, az) {
      final azRad = az * math.pi / 180.0;
      final r = maxR + 14;
      final dx = r * math.sin(azRad);
      final dy = -r * math.cos(azRad);
      _drawText(
        canvas,
        label,
        center + Offset(dx, dy),
        color: Colors.white70,
        fontSize: 13,
        bold: true,
      );
    });
  }

  void _drawConstellation(
      Canvas canvas, PlottedConstellation pc, Offset center, double maxR) {
    final pos = NightSkyMap._project(pc.position, center, maxR);

    // 明るさ演出: 高度が高いほどくっきり
    final opacity = (0.35 + 0.65 * (pc.position.altitude / 90)).clamp(0.35, 1.0);
    final alpha = (opacity * 255).round();

    final dotPaint = Paint()..color = Colors.white.withAlpha(alpha);
    canvas.drawCircle(pos, 3, dotPaint);

    _drawText(
      canvas,
      pc.constellation.emoji,
      pos + const Offset(0, -16),
      fontSize: 16,
      color: Colors.white.withAlpha(alpha),
    );
    _drawText(
      canvas,
      pc.constellation.localizedShortName(languageCode),
      pos + const Offset(0, 10),
      fontSize: 9,
      color: Colors.white60.withAlpha(alpha),
    );
  }

  void _drawBody(Canvas canvas, HorizontalPosition pos, Offset center,
      double maxR, String emoji, double fontSize) {
    final p = NightSkyMap._project(pos, center, maxR);
    _drawText(canvas, emoji, p, fontSize: fontSize);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    Color color = Colors.white,
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(
      canvas,
      position - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) {
    return oldDelegate.constellations != constellations ||
        oldDelegate.moonPosition != moonPosition ||
        oldDelegate.sunPosition != sunPosition ||
        oldDelegate.isDaytime != isDaytime ||
        oldDelegate.languageCode != languageCode;
  }
}
