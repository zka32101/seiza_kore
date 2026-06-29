import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/starfield_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarfieldBackground(
        animate: true,
        seed: 456,
        starCount: 450,
        child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Column(
                        children: [
                          // 🌟 グロー脈動
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) {
                              final glow = 0.55 +
                                  0.45 *
                                      math.sin(_ctrl.value * math.pi * 2);
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber
                                          .withAlpha((140 * glow).toInt()),
                                      blurRadius: 50 * glow,
                                      spreadRadius: 12 * glow,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFAABBFF)
                                          .withAlpha((60 * glow).toInt()),
                                      blurRadius: 30 * glow,
                                      spreadRadius: 4 * glow,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '🌟',
                                  style: TextStyle(fontSize: 72),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 22),

                          // 「星座コレ！」シマーグラデーション
                          AnimatedBuilder(
                            animation: _ctrl,
                            builder: (_, __) {
                              final t = _ctrl.value;
                              return ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: Alignment(-2.5 + 5 * t, 0),
                                  end: Alignment(-1.5 + 5 * t, 0),
                                  colors: const [
                                    Color(0xFFFFCC44), // ゴールド
                                    Color(0xFFFFFFFF), // ホワイト（光芒）
                                    Color(0xFFBBCCFF), // 青白
                                    Color(0xFFFFCC44), // ゴールドに戻る
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height),
                                ),
                                child: const Text(
                                  '星座コレ！',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),

                          // サブタイトル（✦ デコ付き）
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '✦',
                                style: TextStyle(
                                    color: Colors.amber.shade600,
                                    fontSize: 10),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '夜空を向けてコレクション',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontSize: 13,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '✦',
                                style: TextStyle(
                                    color: Colors.amber.shade600,
                                    fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthButton(
                            icon: Icons.person_outline,
                            label: 'ゲストで始める（無料）',
                            onTap: () => context.go('/home'),
                            textColor: Colors.white,
                            fillColor: Colors.white.withAlpha(18),
                            borderColor: Colors.white38,
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            icon: Icons.email_outlined,
                            label: 'メールで登録',
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('メール登録は後で実装')),
                            ),
                            textColor: Colors.white,
                            fillColor: Colors.deepPurple.withAlpha(60),
                            borderColor: Colors.deepPurple.shade300,
                          ),
                          const SizedBox(height: 12),
                          _AuthButton(
                            icon: Icons.g_mobiledata,
                            label: 'Googleで登録',
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Google登録は後で実装')),
                            ),
                            textColor: Colors.white,
                            fillColor: Colors.blue.shade900.withAlpha(60),
                            borderColor: Colors.blue.shade400,
                          ),
                          const SizedBox(height: 32),
                          // Links
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  '利用規約',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(100),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Text(
                                '|',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(50)),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'プライバシーポリシー',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(100),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color textColor;
  final Color fillColor;
  final Color borderColor;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.textColor,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
