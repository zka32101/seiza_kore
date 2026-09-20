import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../data/celestial_bodies_data.dart';

/// 太陽・月・地球を3Dで観察できる学習画面。
/// 上半分はThree.js製の3Dビュー（WebView）、下半分はFlutterネイティブの解説。
class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen> {
  late final WebViewController _controller;
  String _selectedBodyId = 'earth';
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF050818))
      ..addJavaScriptChannel(
        'SolarSystemChannel',
        onMessageReceived: _onJsMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => setState(() => _webViewReady = true),
        ),
      )
      ..loadFlutterAsset('assets/solar_system/index.html');
  }

  void _onJsMessage(JavaScriptMessage message) {
    try {
      final data = json.decode(message.message) as Map<String, dynamic>;
      if (data['type'] == 'select' && data['body'] is String) {
        setState(() => _selectedBodyId = data['body'] as String);
      }
    } catch (_) {
      // 無視: 想定外メッセージ
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = celestialBodies[_selectedBodyId] ?? celestialBodies['earth']!;

    return Scaffold(
      backgroundColor: const Color(0xFF050818),
      appBar: AppBar(
        title: const Text('太陽系3Dビュー'),
        backgroundColor: const Color(0xFF0A0E28),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 3Dビュー（WebView）
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (!_webViewReady)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white70),
                  ),
              ],
            ),
          ),

          // 天体切り替えタブ（横スクロール）
          Container(
            color: const Color(0xFF0A0E28),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: solarSystemDisplayOrder.map((id) {
                  final b = celestialBodies[id];
                  if (b == null) return const SizedBox.shrink();
                  final selected = b.id == _selectedBodyId;
                  return InkWell(
                    onTap: () => setState(() => _selectedBodyId = b.id),
                    child: Container(
                      width: 76,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? const Color(0xFFFFCC55)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(b.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            b.nameJa,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white54,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 解説（スクロール）
          Expanded(
            child: Container(
              color: const Color(0xFF0D1230),
              child: ListView(
                key: ValueKey(_selectedBodyId),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    body.tagline,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _SectionLabel('基礎データ'),
                  const SizedBox(height: 8),
                  _FactsCard(facts: body.facts),
                  const SizedBox(height: 20),

                  ...body.sections.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(s.title),
                          const SizedBox(height: 8),
                          Text(
                            s.body,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.75,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _SectionLabel('豆知識'),
                  const SizedBox(height: 8),
                  ...body.funFacts.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✨ ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC55),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FactsCard extends StatelessWidget {
  final List<CelestialFact> facts;
  const _FactsCard({required this.facts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: facts.map((f) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    f.label,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    f.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
