import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSavingDataModel {
  static const selectedSong = 'selected_song';

  Future<bool> updateCurrentPlayingSong(SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(selectedSong, song.id);
  }

  Future<SongModel?> getCurrentPlayingSong() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final songId = prefs.getInt(selectedSong);
    if (songId == null) {
      return null;
    }
    final songList = await OnAudioQuery().querySongs();
    return songList.firstWhere((element) => element.id == songId);
  }
}
