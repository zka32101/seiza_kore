import 'dart:math';
import '../models/constellation.dart';
import '../models/quiz_question.dart';

/// 星座図鑑のデータから4択クイズを生成するサービス。
/// 「デイリーチャレンジ」用に、日付をシードにして毎日同じ問題セットを
/// 生成できるようにしている（同じ日にアプリを開けば同じ問題になる）。
class QuizService {
  const QuizService._();

  /// 指定した日付のシードで、questionCount問のクイズを生成する。
  /// [languageCode]は'ja'または'en'。問題文・選択肢の言語を切り替える。
  static List<QuizQuestion> generateDailyQuiz({
    required List<Constellation> constellations,
    required DateTime date,
    required String languageCode,
    int questionCount = 5,
  }) {
    if (constellations.length < 4) return [];

    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);

    final pool = constellations.toList()..shuffle(random);
    final targets = pool.take(questionCount).toList();

    final questions = <QuizQuestion>[];
    for (var i = 0; i < targets.length; i++) {
      final target = targets[i];
      // 問題タイプを星座ごとに切り替えてバリエーションを出す
      final type = i % 3;
      final question = switch (type) {
        0 => _buildEmojiQuestion(target, constellations, random, i, languageCode),
        1 => _buildMythologyQuestion(target, constellations, random, i, languageCode),
        _ => _buildSeasonQuestion(target, constellations, random, i, languageCode),
      };
      if (question != null) questions.add(question);
    }
    return questions;
  }

  static String _localizedName(Constellation c, String languageCode) =>
      languageCode == 'en' ? c.nameEn : c.nameJa;

  static List<String> _pickDistractors(
    Constellation target,
    List<Constellation> all,
    Random random,
    int count,
    String languageCode,
  ) {
    final others = all.where((c) => c.id != target.id).toList()..shuffle(random);
    return others.take(count).map((c) => _localizedName(c, languageCode)).toList();
  }

  static List<String> _shuffledChoices(
    String correct,
    List<String> distractors,
    Random random,
  ) {
    final choices = [correct, ...distractors]..shuffle(random);
    return choices;
  }

  static QuizQuestion? _buildEmojiQuestion(
    Constellation target,
    List<Constellation> all,
    Random random,
    int index,
    String languageCode,
  ) {
    final distractors = _pickDistractors(target, all, random, 3, languageCode);
    if (distractors.length < 3) return null;
    final name = _localizedName(target, languageCode);
    final choices = _shuffledChoices(name, distractors, random);
    final questionText = languageCode == 'en'
        ? 'Which constellation does this symbol represent?'
        : 'このマークが表す星座は？';
    return QuizQuestion(
      id: 'emoji_${target.id}_$index',
      prompt: '${target.emoji}\n$questionText',
      choices: choices,
      correctIndex: choices.indexOf(name),
      explanation: target.localizedMythology(languageCode),
      relatedConstellationId: target.id,
    );
  }

  static QuizQuestion? _buildMythologyQuestion(
    Constellation target,
    List<Constellation> all,
    Random random,
    int index,
    String languageCode,
  ) {
    final mythology = target.localizedMythology(languageCode);
    if (mythology.isEmpty) return null;
    final distractors = _pickDistractors(target, all, random, 3, languageCode);
    if (distractors.length < 3) return null;
    final name = _localizedName(target, languageCode);
    final choices = _shuffledChoices(name, distractors, random);
    final snippet = mythology.length > 60
        ? '${mythology.substring(0, 60)}…'
        : mythology;
    final prompt = languageCode == 'en'
        ? 'Which constellation does the following myth belong to?\n"$snippet"'
        : '次の神話が伝わる星座は？\n「$snippet」';
    return QuizQuestion(
      id: 'myth_${target.id}_$index',
      prompt: prompt,
      choices: choices,
      correctIndex: choices.indexOf(name),
      explanation: mythology,
      relatedConstellationId: target.id,
    );
  }

  static QuizQuestion? _buildSeasonQuestion(
    Constellation target,
    List<Constellation> all,
    Random random,
    int index,
    String languageCode,
  ) {
    final peakMonths = target.localizedPeakMonths(languageCode);
    if (peakMonths.isEmpty) return null;
    final distractors = _pickDistractors(target, all, random, 3, languageCode);
    if (distractors.length < 3) return null;
    final name = _localizedName(target, languageCode);
    final choices = _shuffledChoices(name, distractors, random);
    final prompt = languageCode == 'en'
        ? 'Which constellation is best viewed in $peakMonths?'
        : '「$peakMonths」に見頃を迎える星座は？';
    final explanation = languageCode == 'en'
        ? '$name is best seen in $peakMonths. ${target.localizedObservationTips(languageCode)}'
        : '$nameは${peakMonths}によく見える星座です。${target.localizedObservationTips(languageCode)}';
    return QuizQuestion(
      id: 'season_${target.id}_$index',
      prompt: prompt,
      choices: choices,
      correctIndex: choices.indexOf(name),
      explanation: explanation,
      relatedConstellationId: target.id,
    );
  }
}
