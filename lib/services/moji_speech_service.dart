import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MojiSpeechService {
  MojiSpeechService({FlutterTts? flutterTts}) : _tts = flutterTts ?? FlutterTts();

  final FlutterTts _tts;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.52);
      await _tts.setPitch(1.25);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(false);
      _ready = true;
    } catch (error, stackTrace) {
      debugPrint('MOJI TTS init error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> speak(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await init();

    try {
      await _tts.stop();
      await _tts.speak(cleanText);
    } catch (error, stackTrace) {
      debugPrint('MOJI TTS speak error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (error, stackTrace) {
      debugPrint('MOJI TTS stop error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
