import 'package:flutter_tts/flutter_tts.dart';

/// Singleton TTS Service để quản lý Text-to-Speech toàn app
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  String? _currentText;

  /// Initialize TTS
  Future<void> initialize() async {
    await _flutterTts.setLanguage('vi-VN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _currentText = null;
    });

    _flutterTts.setErrorHandler((message) {
      _isPlaying = false;
      _currentText = null;
    });
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Nếu đang đọc cùng text, thì dừng
    if (_isPlaying && _currentText == text) {
      await stop();
      return;
    }

    // Nếu đang đọc text khác, dừng và đọc text mới
    if (_isPlaying) {
      await stop();
    }

    _isPlaying = true;
    _currentText = text;
    await _flutterTts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    _currentText = null;
  }

  /// Check if currently playing
  bool get isPlaying => _isPlaying;

  /// Get current text being spoken
  String? get currentText => _currentText;

  /// Check if specific text is being spoken
  bool isSpeaking(String text) => _isPlaying && _currentText == text;
}
