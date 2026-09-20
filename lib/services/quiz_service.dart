import 'dart:math';
import '../models/constellation.dart';
import '../models/quiz_question.dart';

/// 星座図鑑のデータから4択クイズを生成するサービス。
/// 「デイリーチャレンジ」用に、日付をシードにして毎日同じ問題セットを
/// 生成できるようにしている（同じ日にアプリを開けば同じ問題になる）。
class QuizService {
  const QuizService._();

  /// 指定した日付のシードで、questionCount問のクイズを生成する。
  static List<QuizQuestion> generateDailyQuiz({
    required List<Constellation> constellations,
    required DateTime date,
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
        0 => _buildEmojiQuestion(target, constellations, random, i),
        1 => _buildMythologyQuestion(target, constellations, random, i),
        _ => _buildSeasonQuestion(target, constellations, random, i),
      };
      if (question != null) questions.add(question);
    }
    return questions;
  }

  static List<String> _pickDistractors(
    Constellation target,
    List<Constellation> all,
    Random random,
    int count,
  ) {
    final others = all.where((c) => c.id != target.id).toList()..shuffle(random);
    return others.take(count).map((c) => c.nameJa).toList();
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
  ) {
    final distractors = _pickDistractors(target, all, random, 3);
    if (distractors.length < 3) return null;
    final choices = _shuffledChoices(target.nameJa, distractors, random);
    return QuizQuestion(
      id: 'emoji_${target.id}_$index',
      prompt: '${target.emoji}\nこのマークが表す星座は？',
      choices: choices,
      correctIndex: choices.indexOf(target.nameJa),
      explanation: target.mythologyText,
      relatedConstellationId: target.id,
    );
  }

  static QuizQuestion? _buildMythologyQuestion(
    Constellation target,
    List<Constellation> all,
    Random random,
    int index,
  ) {
    if (target.mythologyText.isEmpty) return null;
    final distractors = _pickDistractors(target, all, random, 3);
    if (distractors.length < 3) return null;
    final choices = _shuffledChoices(target.nameJa, distractors, random);
    final snippet = target.mythologyText.length > 60
        ? '${target.mythologyText.substring(0, 60)}…'
        : target.mythologyText;
    return QuizQuestion(
      id: 'myth_${target.id}_$index',
      prompt: '次の神話が伝わる星座は？\n「$snippet」',
      choices: choices,
      correctIndex: choices.indexOf(target.nameJa),
      explanation: target.mythologyText,
      relatedConstellationId: target.id,
    );
  }

  static QuizQuestion? _buildSeasonQuestion(
    Constellation target,
    List<Constellation> all,
    Random random,
    int index,
  ) {
    if (target.peakMonths.isEmpty) return null;
    final distractors = _pickDistractors(target, all, random, 3);
    if (distractors.length < 3) return null;
    final choices = _shuffledChoices(target.nameJa, distractors, random);
    return QuizQuestion(
      id: 'season_${target.id}_$index',
      prompt: '「${target.peakMonths}」に見頃を迎える星座は？',
      choices: choices,
      correctIndex: choices.indexOf(target.nameJa),
      explanation:
          '${target.nameJa}は${target.peakMonths}によく見える星座です。${target.observationTips}',
      relatedConstellationId: target.id,
    );
  }
}
