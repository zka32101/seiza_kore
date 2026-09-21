import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../l10n/generated/app_localizations.dart';

/// テキストを音声で読み上げる/停止するトグルボタン。
class ReadAloudButton extends StatefulWidget {
  final String text;
  final String languageCode;
  const ReadAloudButton({
    super.key,
    required this.text,
    required this.languageCode,
  });

  @override
  State<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends State<ReadAloudButton> {
  bool _isSpeaking = false;

  Future<void> _toggle() async {
    if (_isSpeaking) {
      await TtsService.instance.stop();
      if (mounted) setState(() => _isSpeaking = false);
      return;
    }
    setState(() => _isSpeaking = true);
    await TtsService.instance.speak(widget.text, languageCode: widget.languageCode);
    if (mounted) setState(() => _isSpeaking = false);
  }

  @override
  void dispose() {
    if (_isSpeaking) {
      TtsService.instance.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      icon: Icon(_isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_outlined),
      tooltip: _isSpeaking ? l10n.readAloudStopTooltip : l10n.readAloudTooltip,
      onPressed: _toggle,
      visualDensity: VisualDensity.compact,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
