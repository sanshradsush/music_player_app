import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSavingDataModel {
  static const selectedSong = 'selected_song';
  static const likedSongs = 'liked_songs';
  static const isShuffle = 'is_shuffle';
  static const isRepeat = 'is_repeat';
  static const playList = 'play_list';

  Future<bool> updateCurrentPlayingSong(SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(selectedSong, song.id);
  }

  Future<bool> updatePlayShuffle(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(isShuffle, value);
  }

  Future<bool> getShuffle() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isShuffle) ?? true;
  }

  Future<bool> updatePlayRepeat(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(isRepeat, value);
  }

  Future<bool> getPlayRepeat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isRepeat) ?? false;
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

  // Create new play list
  Future<bool> createNewPlayList(String playListName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> playLists = (prefs.getStringList(playList) ?? []);
    if (playLists.contains(playListName)) {
      return false;
    }
    playLists.add(playListName);
    return prefs.setStringList(playList, playLists);
  }

  // Get all play lists
  Future<List<String>> getPlayLists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(playList) ?? [];
  }
}
