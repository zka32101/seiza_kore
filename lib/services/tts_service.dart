import 'package:flutter_tts/flutter_tts.dart';

/// アプリ全体で共有する読み上げ（TTS）サービス。
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> speak(String text, {required String languageCode}) async {
    await _ensureInitialized();
    await _tts.setLanguage(languageCode == 'en' ? 'en-US' : 'ja-JP');
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
