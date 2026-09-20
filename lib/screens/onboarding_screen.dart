import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/generated/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  List<_PageData> _pages(AppLocalizations l10n) => [
        _PageData(
          emoji: '🌟',
          title: l10n.onboardingPage1Title,
          subtitle: l10n.onboardingPage1Subtitle,
          description: l10n.onboardingPage1Description,
          accentColor: const Color(0xFFAACCFF),
          backgroundImage: 'assets/onboarding/onboarding_bg_2_collection.png',
        ),
        _PageData(
          emoji: '🏙️',
          title: l10n.onboardingPage2Title,
          subtitle: l10n.onboardingPage2Subtitle,
          description: l10n.onboardingPage2Description,
          accentColor: const Color(0xFFCC99FF),
          backgroundImage: 'assets/onboarding/onboarding_bg_1_discovery.png',
        ),
        _PageData(
          emoji: '⏰',
          title: l10n.onboardingPage3Title,
          subtitle: l10n.onboardingPage3Subtitle,
          description: l10n.onboardingPage3Description,
          accentColor: const Color(0xFFFFCC88),
          backgroundImage: 'assets/onboarding/onboarding_bg_3_timetravel.png',
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

  static const _pageCount = 3;

  void _next() {
    if (_currentPage < _pageCount - 1) {
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
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages(l10n);
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: pages.length,
            itemBuilder: (_, i) => _OnboardingPage(data: pages[i]),
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
                      children: List.generate(pages.length, (i) {
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
                          _currentPage == pages.length - 1
                              ? l10n.onboardingStart
                              : l10n.onboardingNext,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (_currentPage < pages.length - 1)
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          l10n.onboardingSkip,
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
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
  final Color accentColor;
  final String backgroundImage;

  const _PageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.accentColor,
    required this.backgroundImage,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(data.backgroundImage, fit: BoxFit.cover),
        // 下から暗くして文字を読みやすくするスクリム
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(60),
                Colors.black.withAlpha(140),
                Colors.black.withAlpha(220),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        _OnboardingPageContent(data: data),
      ],
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  final _PageData data;
  const _OnboardingPageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
      );
  }
}
