import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicSettings {
  // Private constructor
  MusicSettings._();

  // Singleton instance
  static final MusicSettings _instance = MusicSettings._();

  OnAudioQuery audioQuery = OnAudioQuery();
  Logger logger = Logger();

  // Getter to access the instance
  static MusicSettings get instance => _instance;

  static SongModel? selectedSong;
  static List<SongModel> songs = [];
  static bool isShuffle = false;
  static bool isRepeat = false;
  static bool isLooped = false;


  set setSelectedSong(SongModel? value) {
    selectedSong = value;
  }

  // Add your methods and properties here
  Future<List<SongModel>> fetchAudioFiles() async {
    try {
      songs = await audioQuery.querySongs();

      logger.i('Audio files fetched successfully from the device');
    } catch (e) {
      logger.e('Error fetching audio files: $e');
    }
    return songs;
  }

  Future<List<AlbumModel>> fetchAlbums() async {
    List<AlbumModel> albums = [];
    try {
      albums = await audioQuery.queryAlbums();

      logger.i('Albums fetched successfully from the device --> $albums');
    } catch (e) {
      logger.e('Error fetching albums: $e');
    }
    return albums;
  }

  Future<List<ArtistModel>> fetchArtists() async {
    List<ArtistModel> artists = [];
    try {
      artists = await audioQuery.queryArtists();

      logger.i('Artists fetched successfully from the device --> $artists');
    } catch (e) {
      logger.e('Error fetching artists: $e');
    }
    return artists;
  }

  Future<List<PlaylistModel>> fetchPlaylists() async {
    List<PlaylistModel> playlists = [];
    try {
      playlists = await audioQuery.queryPlaylists();

      logger.i('Playlists fetched successfully from the device --> $playlists');
    } catch (e) {
      logger.e('Error fetching playlists: $e');
    }
    return playlists;
  }

  Future<bool> createPlaylist(String playlistName) async {
    try {
      final playlist = await fetchPlaylists();

      for (PlaylistModel playlistModel in playlist) {
        if (playlistModel.playlist == playlistName) {
          logger.i('Playlist is already created with the name: $playlistName');
          return false;
        }
      }

      await audioQuery.createPlaylist(playlistName);
      logger.i('Playlist created successfully');
    } catch (e) {
      logger.e('Error creating playlist: $e');
      return false;
    }
    return true;
  }

  Future<bool> deletePlaylist(int playlistId) async {
    try {
      await audioQuery.removePlaylist(playlistId);
      logger.i('Playlist deleted successfully');
    } catch (e) {
      logger.e('Error deleting playlist: $e');
      return false;
    }
    return true;
  }

  Future<bool> addToPlaylist(int playlistId, int songId) async {
    try {
      await audioQuery.addToPlaylist(playlistId, songId);
      logger.i('Song added to playlist successfully');
    } catch (e) {
      logger.e('Error adding song to playlist: $e');
      return false;
    }
    return true;
  }

  Future<bool> removeFromPlaylist(int playlistId, int songId) async {
    try {
      await audioQuery.removeFromPlaylist(playlistId, songId);
      logger.i('Song removed from playlist successfully');
    } catch (e) {
      logger.e('Error removing song from playlist: $e');
      return false;
    }
    return true;
  }
}
