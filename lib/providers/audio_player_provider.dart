import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioPlayerState {
  final String? articleId;
  final String? title;
  final String? imageUrl;
  final String? text;
  final bool isPlaying;
  final bool isPaused;
  final double speechRate;
  final String speedLabel;
  final bool isBrief;

  const AudioPlayerState({
    this.articleId,
    this.title,
    this.imageUrl,
    this.text,
    this.isPlaying = false,
    this.isPaused = false,
    this.speechRate = 0.5,
    this.speedLabel = '1.0x',
    this.isBrief = true,
  });

  bool get hasActiveAudio => articleId != null && (isPlaying || isPaused);

  AudioPlayerState copyWith({
    String? articleId,
    String? title,
    String? imageUrl,
    String? text,
    bool? isPlaying,
    bool? isPaused,
    double? speechRate,
    String? speedLabel,
    bool? isBrief,
    bool clearActive = false,
  }) {
    if (clearActive) {
      return AudioPlayerState(
        speechRate: speechRate ?? this.speechRate,
        speedLabel: speedLabel ?? this.speedLabel,
      );
    }
    return AudioPlayerState(
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      text: text ?? this.text,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      speechRate: speechRate ?? this.speechRate,
      speedLabel: speedLabel ?? this.speedLabel,
      isBrief: isBrief ?? this.isBrief,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final FlutterTts _flutterTts = FlutterTts();

  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _initTts();
  }

  void _initTts() {
    _flutterTts.setLanguage('vi-VN');
    _flutterTts.setSpeechRate(state.speechRate);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      state = state.copyWith(isPlaying: false, isPaused: false);
    });

    _flutterTts.setErrorHandler((msg) {
      state = state.copyWith(isPlaying: false, isPaused: false);
    });

    _flutterTts.setPauseHandler(() {
      state = state.copyWith(isPlaying: false, isPaused: true);
    });

    _flutterTts.setContinueHandler(() {
      state = state.copyWith(isPlaying: true, isPaused: false);
    });
  }

  Future<void> playArticle({
    required String id,
    required String title,
    required String text,
    String? imageUrl,
    bool isBrief = true,
  }) async {
    if (text.trim().isEmpty) return;

    // Nếu đang phát cùng 1 bài và cùng chế độ brief/full
    if (state.articleId == id && state.isBrief == isBrief) {
      if (state.isPlaying) {
        await pause();
        return;
      } else if (state.isPaused) {
        await resume();
        return;
      }
    }

    // Dừng âm thanh cũ nếu có
    await _flutterTts.stop();

    state = state.copyWith(
      articleId: id,
      title: title,
      imageUrl: imageUrl,
      text: text,
      isPlaying: true,
      isPaused: false,
      isBrief: isBrief,
    );

    await _flutterTts.setSpeechRate(state.speechRate);
    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    if (state.isPlaying) {
      await _flutterTts.pause();
      state = state.copyWith(isPlaying: false, isPaused: true);
    }
  }

  Future<void> resume() async {
    if (state.isPaused && state.text != null) {
      state = state.copyWith(isPlaying: true, isPaused: false);
      await _flutterTts.speak(state.text!);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else if (state.isPaused) {
      await resume();
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    state = state.copyWith(clearActive: true);
  }

  Future<void> cycleSpeed() async {
    // 0.75x (0.42) -> 1.0x (0.50) -> 1.25x (0.58) -> 1.5x (0.68)
    double nextRate;
    String nextLabel;

    if (state.speedLabel == '1.0x') {
      nextRate = 0.58;
      nextLabel = '1.25x';
    } else if (state.speedLabel == '1.25x') {
      nextRate = 0.68;
      nextLabel = '1.5x';
    } else if (state.speedLabel == '1.5x') {
      nextRate = 0.42;
      nextLabel = '0.75x';
    } else {
      nextRate = 0.50;
      nextLabel = '1.0x';
    }

    state = state.copyWith(speechRate: nextRate, speedLabel: nextLabel);
    await _flutterTts.setSpeechRate(nextRate);
  }
}

final audioPlayerProvider = StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});
