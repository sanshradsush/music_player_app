import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSavingDataModel {
  static const selectedSong = 'selected_song';
  static const likedSongs = 'liked_songs';

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

  Future<List<SongModel>> getLikedSongs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> likedSong = (prefs.getStringList(likedSongs) ?? []);
    final songList = await OnAudioQuery().querySongs();
    return songList
        .where((element) => likedSong.contains(element.id.toString()))
        .toList();
  }

  Future<bool> addLikedSong(SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> likedSong = (prefs.getStringList(likedSongs) ?? []);
    if (likedSong.contains(song.id.toString())) {
      return false;
    }
    likedSong.add(song.id.toString());
    return prefs.setStringList(likedSongs, likedSong);
  }

  Future<bool> removeLikedSong(SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> likedSong = (prefs.getStringList(likedSongs) ?? []);
    likedSong.remove(song.id.toString());
    return prefs.setStringList(likedSongs, likedSong);
  }

  Future<bool> checkForLikedSong(SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(likedSongs) ?? []).contains(song.id.toString());
  }
}
