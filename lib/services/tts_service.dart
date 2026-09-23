import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service managing Text-to-Speech (TTS) playback with state tracking.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  final ValueNotifier<bool> isSpeaking = ValueNotifier<bool>(false);
  bool _isInitialized = false;

  /// Initializes the TTS engine with natural Arabic speech parameters.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setSpeechRate(0.48); // Slightly measured pace for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        isSpeaking.value = true;
      });

      _flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
      });

      _flutterTts.setCancelHandler(() {
        isSpeaking.value = false;
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        isSpeaking.value = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS Init Error: $e');
    }
  }

  /// Speaks the provided text in the target language (defaults to Arabic).
  Future<void> speak(String text, {String languageCode = 'ar'}) async {
    final String cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await init();

    try {
      if (isSpeaking.value) {
        await stop();
      }

      // Set language according to locale
      final String tag = languageCode.startsWith('en') ? 'en-US' : 'ar-SA';
      await _flutterTts.setLanguage(tag);
      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      isSpeaking.value = false;
    }
  }

  /// Stops any ongoing speech.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      isSpeaking.value = false;
    } catch (e) {
      debugPrint('TTS Stop Error: $e');
    }
  }

  void dispose() {
    _flutterTts.stop();
    isSpeaking.dispose();
  }
}
