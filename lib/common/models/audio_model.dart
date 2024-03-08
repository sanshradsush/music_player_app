import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'music_settings_model.dart';
import 'shared_data_model.dart';

class AudioPlayerModel extends ChangeNotifier {
  static final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  bool _disposed = false;

  double get totalDuration =>
      (_audioPlayer.duration?.inSeconds ?? 0).toDouble();
  double get currentPosition => _currentPosition;

  SongModel? _currentSong;

  SongModel? get currentSong => _currentSong;

  set currentSong(SongModel? value) {
    _currentSong = value;
    LocalSavingDataModel().updateCurrentPlayingSong(value!);
    MusicSettings.instance.setSelectedSong = value;
    _currentPosition = 0.0;
    playLocalMusic(value.data);
    notifyListeners();
  }

  set currentPosition(double value) {
    _currentPosition = value;
    notifyListeners();
  }

  bool get isPlaying => _isPlaying;

  AudioPlayerModel() {
    _audioPlayer.playerStateStream.listen((PlayerState state) {
      _isPlaying = state.playing;
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

  Future<void> seekTo(double value) async {
    await _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  Future<void> playLocalMusic(String? path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(path ?? '');
      await _audioPlayer.play();
      Logger().i('playing audio: ');
    } catch (e) {
      Logger().e('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  
}
