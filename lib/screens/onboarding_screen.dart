import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/starfield_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      emoji: '🌟',
      title: '夜空を図鑑にしよう',
      subtitle: '88星座コレクション',
      description: 'スマホを夜空に向けて星座を発見しよう。見るたびに図鑑が充実して、自分だけのコレクションが完成する。',
      seed: 101,
      overlay: Color(0x22102070), // 青みがかった宇宙
      accentColor: Color(0xFFAACCFF),
    ),
    _PageData(
      emoji: '🏙️',
      title: 'シティ・ライト・チャレンジ',
      subtitle: '難易度で何度も楽しめる',
      description: '都市の光の中でも星座を探そう。Bortleスケール1〜9で難易度が変わる。都市観測を達成すると特別な称号がもらえる！',
      seed: 202,
      overlay: Color(0x28330020), // 紫がかった都市の夜
      accentColor: Color(0xFFCC99FF),
    ),
    _PageData(
      emoji: '⏰',
      title: '特別な夜は永遠に',
      subtitle: 'タイムカプセル天体',
      description: '流星群・月食などのレアイベント期間中のみ解放される特別な記録ページ。見逃したら来年まで待つしかない！',
      seed: 303,
      overlay: Color(0x20002838), // 深いティール
      accentColor: Color(0xFFFFCC88),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.amber
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'はじめる！' : '次へ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'スキップ',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      )
                    else
                      const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final int seed;
  final Color overlay;
  final Color accentColor;

  const _PageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.seed,
    required this.overlay,
    required this.accentColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return StarfieldBackground(
      seed: data.seed,
      starCount: 380,
      overlayColor: data.overlay,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 160),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 絵文字に光のグロー
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withAlpha(80),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Text(data.emoji, style: const TextStyle(fontSize: 88)),
              ),
              const SizedBox(height: 36),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: data.accentColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: data.accentColor.withAlpha(100)),
                ),
                child: Text(
                  data.subtitle,
                  style: TextStyle(
                    color: data.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.7,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
