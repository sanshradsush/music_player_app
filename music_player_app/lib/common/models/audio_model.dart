import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerModel extends ChangeNotifier {
  static final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  bool _disposed = false;

  double get totalDuration =>
      (_audioPlayer.duration?.inSeconds ?? 0).toDouble();
  double get currentPosition => _currentPosition;

  bool get isPlaying => _isPlaying;

  AudioPlayerModel() {
    _audioPlayer.playerStateStream.listen((PlayerState state) {
      if (state.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      if (_disposed == false) notifyListeners();
    });

    _audioPlayer.positionStream.listen((Duration position) {
      // Handle position changes
      _currentPosition = position.inSeconds.toDouble();
      if (_disposed == false) notifyListeners();
    });
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void seekTo(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  void playLocalMusic(String? path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(path ?? '');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
