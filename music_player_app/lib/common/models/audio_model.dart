import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerModel extends ChangeNotifier {
  static final audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  double get totalDuration => (audioPlayer.duration?.inSeconds ?? 0).toDouble();
  double get currentPosition => audioPlayer.position.inSeconds.toDouble();

  bool get isPlaying => _isPlaying;

  AudioPlayerModel() {
    audioPlayer.playerStateStream.listen((PlayerState state) {
      // if (state == PlayerState.playing) {
      //   _isPlaying = true;
      // } else {
      //   _isPlaying = false;
      // }
      notifyListeners();
    });
  }

  void togglePlayPause() {
    if (_isPlaying) {
      audioPlayer.pause();
    } else {
      // _audioPlayer.resume();
    }
  }

  void seekTo(double value) {
    audioPlayer.seek(Duration(seconds: value.toInt()));
  }
}
