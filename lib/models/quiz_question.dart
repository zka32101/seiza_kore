/// クイズの1問を表すモデル。4択形式。
class QuizQuestion {
  final String id;
  final String prompt;
  final List<String> choices;
  final int correctIndex;

  /// 正解時に表示する豆知識・解説
  final String explanation;

  /// 関連する星座ID（詳細画面への導線に使う）
  final String? relatedConstellationId;

  const QuizQuestion({
    required this.id,
    required this.prompt,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    this.relatedConstellationId,
  });

  String get correctAnswer => choices[correctIndex];
}

/// 1回分のクイズセッションの結果
class QuizResult {
  final int totalQuestions;
  final int correctCount;

  const QuizResult({required this.totalQuestions, required this.correctCount});

  double get accuracy => totalQuestions == 0 ? 0 : correctCount / totalQuestions;

  String get gradeEmoji {
    final pct = accuracy;
    if (pct >= 1.0) return '🏆';
    if (pct >= 0.8) return '🌟';
    if (pct >= 0.6) return '✨';
    if (pct >= 0.4) return '🌙';
    return '🔭';
  }

  String get gradeMessage {
    final pct = accuracy;
    if (pct >= 1.0) return '満点！星博士だね！';
    if (pct >= 0.8) return 'すごい！星にくわしいね！';
    if (pct >= 0.6) return 'いいね！もう少しで星マスター！';
    if (pct >= 0.4) return 'なかなか！図鑑でもっと調べてみよう';
    return 'これから星座をたくさん覚えていこう！';
  }
}
