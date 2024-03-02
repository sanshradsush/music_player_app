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

}
