import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/constellation_provider.dart';
import '../models/quiz_question.dart';
import '../services/quiz_service.dart';
import '../l10n/generated/app_localizations.dart';

/// 星座デイリークイズ画面。星座図鑑のデータから毎日5問の4択クイズを出題する。
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedChoice;
  bool _answered = false;

  void _selectChoice(int index, QuizQuestion question) {
    if (_answered) return;
    setState(() {
      _selectedChoice = index;
      _answered = true;
      if (index == question.correctIndex) _correctCount++;
    });
  }

  void _next(int total) {
    setState(() {
      _currentIndex++;
      _selectedChoice = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final constellationsAsync = ref.watch(constellationListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1230),
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        backgroundColor: const Color(0xFF0A0E28),
        foregroundColor: Colors.white,
      ),
      body: constellationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => Center(
          child: Text(l10n.quizLoadError(e.toString()),
              style: const TextStyle(color: Colors.white70)),
        ),
        data: (all) {
          final questions = QuizService.generateDailyQuiz(
            constellations: all,
            date: DateTime.now(),
            languageCode: lang,
          );

          if (questions.isEmpty) {
            return Center(
              child: Text(l10n.quizNotReady, style: const TextStyle(color: Colors.white70)),
            );
          }

          if (_currentIndex >= questions.length) {
            return _ResultView(
              result: QuizResult(
                totalQuestions: questions.length,
                correctCount: _correctCount,
              ),
              onRetry: () => setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _selectedChoice = null;
                _answered = false;
              }),
            );
          }

          final question = questions[_currentIndex];
          return _QuestionView(
            question: question,
            questionNumber: _currentIndex + 1,
            totalQuestions: questions.length,
            selectedChoice: _selectedChoice,
            answered: _answered,
            onSelect: (i) => _selectChoice(i, question),
            onNext: () => _next(questions.length),
            onOpenDetail: question.relatedConstellationId == null
                ? null
                : () => context
                    .push('/constellation/${question.relatedConstellationId}'),
          );
        },
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedChoice;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final VoidCallback? onOpenDetail;

  const _QuestionView({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedChoice,
    required this.answered,
    required this.onSelect,
    required this.onNext,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 進捗バー
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: questionNumber / totalQuestions,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFCC55)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.quizQuestionProgress(questionNumber, totalQuestions),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // 問題文
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.prompt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.6,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // 選択肢
          Expanded(
            child: ListView.separated(
              itemCount: question.choices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final isCorrect = i == question.correctIndex;
                final isSelected = i == selectedChoice;

                Color bg = Colors.white.withAlpha(20);
                Color border = Colors.transparent;
                if (answered) {
                  if (isCorrect) {
                    bg = Colors.green.withAlpha(60);
                    border = Colors.greenAccent;
                  } else if (isSelected) {
                    bg = Colors.red.withAlpha(60);
                    border = Colors.redAccent;
                  }
                }

                return InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border, width: 2),
                    ),
                    child: Text(
                      question.choices[i],
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),

          if (answered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedChoice == question.correctIndex
                        ? l10n.quizCorrect
                        : l10n.quizExplanationLabel,
                    style: const TextStyle(
                      color: Color(0xFFFFCC55),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  if (onOpenDetail != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onOpenDetail,
                      child: Text(l10n.quizViewDetail),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onNext,
                child: Text(
                  questionNumber < totalQuestions
                      ? l10n.quizNextQuestion
                      : l10n.quizSeeResult,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final QuizResult result;
  final VoidCallback onRetry;

  const _ResultView({required this.result, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.gradeEmoji, style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              l10n.quizScoreLabel(result.correctCount, result.totalQuestions),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              result.gradeMessage,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: Text(l10n.quizRetry),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                child: Text(l10n.quizBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
