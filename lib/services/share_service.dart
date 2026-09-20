import 'package:share_plus/share_plus.dart';
import '../models/observation.dart';
import '../models/constellation.dart';

/// 観測記録・実績をSNS等で共有するためのサービス。
/// 現時点ではテキスト共有のみ（画像化は将来の拡張として検討）。
class ShareService {
  const ShareService._();

  static const String _appHashtags = '#星座コレ #星空観測';

  static Future<void> shareObservation({
    required Observation observation,
    required Constellation constellation,
  }) async {
    final date = '${observation.timestamp.year}年'
        '${observation.timestamp.month}月${observation.timestamp.day}日';
    final diffStars =
        '★' * observation.difficultyStars + '☆' * (3 - observation.difficultyStars);

    final text = StringBuffer()
      ..writeln('${constellation.emoji} ${constellation.nameJa}を観測しました！')
      ..writeln('📅 $date')
      ..writeln('📍 ${observation.locationName}')
      ..writeln('🌌 光害レベル: Bortle ${observation.bortleScale} $diffStars')
      ..writeln()
      ..write(_appHashtags);

    await SharePlus.instance.share(ShareParams(text: text.toString()));
  }

  static Future<void> shareAchievement({
    required String title,
    required String description,
    required String emoji,
  }) async {
    final text = StringBuffer()
      ..writeln('$emoji 実績を解除しました！「$title」')
      ..writeln(description)
      ..writeln()
      ..write(_appHashtags);

    await SharePlus.instance.share(ShareParams(text: text.toString()));
  }

  static Future<void> shareQuizResult({
    required int correctCount,
    required int totalQuestions,
  }) async {
    final text = StringBuffer()
      ..writeln('❓ 今日の星座クイズで$correctCount/$totalQuestions問正解しました！')
      ..writeln()
      ..write(_appHashtags);

    await SharePlus.instance.share(ShareParams(text: text.toString()));
  }
}
