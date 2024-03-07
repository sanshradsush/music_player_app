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

  /*
  Existing Playlists
  Example: ["playListName1", "playListName2", "playListName3"] or []

  ******************************************************
  Create new playListName4:

  ["playListName1", "playListName2", "playListName3", "playListName4"] or ["playListName4"]
   */
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
  /*
  Example: ["playListName1", "playListName2", "playListName3"]
  */

  Future<List<String>> getPlayLists() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(playList) ?? [];
  }

  //Remove a play list

  /*
  Example: ["playListName1", "playListName2", "playListName3"]

  ******************************************************

  Remove playListName2:

   ["playListName1", "playListName3"]

  */

  Future<bool> removePlayList(String playListName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> playLists = (prefs.getStringList(playList) ?? []);
    if (!playLists.contains(playListName)) {
      return false;
    }
    playLists.remove(playListName);
    return prefs.setStringList(playList, playLists);
  }

  //Get the songs from a play list
  /*
  Example: {
   "playListName1": ["songId1", "songId2", "songId3"]
    "playListName2": ["songId3", "songId4", "songId1"]
  }
  */

  Future<List<SongModel>> getPlayListSongs(String playListName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> playListSongs =
        (prefs.getStringList(playListName) ?? []);
    final songList = await OnAudioQuery().querySongs();
    return songList
        .where((element) => playListSongs.contains(element.id.toString()))
        .toList();
  }

  // Add song to a play list
  /*

  ******************************************************
  Existing Playlists with songs

  Example: {
   "playListName1": ["songId1", "songId2", "songId3"]
    "playListName2": ["songId3", "songId4", "songId1"]
  }
  
  ******************************************************

  Add songId4 to playListName1:

  {
   "playListName1": ["songId1", "songId2", "songId3", "songId4"]
    "playListName2": ["songId3", "songId4", "songId1"]
  }

  ******************************************************
  */

  Future<bool> addSongToPlayList(String playListName, SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> playListSongs =
        (prefs.getStringList(playListName) ?? []);
    if (playListSongs.contains(song.id.toString())) {
      return false;
    }
    playListSongs.add(song.id.toString());
    return prefs.setStringList(playListName, playListSongs);
  }

  // Remove song from a play list

  /*

  ******************************************************
  Existing Playlists with songs

  Example: {
   "playListName1": ["songId1", "songId2", "songId3"]
    "playListName2": ["songId3", "songId4", "songId1"]
  }
  
  ******************************************************

  Remove songId1 from playListName2:

  {
   "playListName1": ["songId1", "songId2", "songId3", "songId4"]
    "playListName2": ["songId3", "songId4"]
  }

  ******************************************************
  */
  Future<bool> removeSongFromPlayList(
      String playListName, SongModel song) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> playListSongs =
        (prefs.getStringList(playListName) ?? []);
    playListSongs.remove(song.id.toString());
    return prefs.setStringList(playListName, playListSongs);
  }
}
