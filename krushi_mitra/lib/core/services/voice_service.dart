import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isSttInitialized = false;

  // Initialize Speech to Text
  Future<bool> initSpeech() async {
    if (!_isSttInitialized) {
      _isSttInitialized = await _speechToText.initialize(
        onError: (error) => debugPrint('STT Error: $error'),
        onStatus: (status) => debugPrint('STT Status: $status'),
      );
    }
    return _isSttInitialized;
  }

  // Speak Text
  Future<void> speak(String text, {String languageCode = 'en-US'}) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.setSpeechRate(0.5); // Slower rate for rural comprehension
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  // Stop Speaking
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Start Listening
  Future<void> startListening(Function(String) onResult, {String localeId = 'en_US'}) async {
    if (await initSpeech()) {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
      );
    }
  }

  // Stop Listening
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
