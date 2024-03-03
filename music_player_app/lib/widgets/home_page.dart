import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../common/models/audio_model.dart';
import '../common/models/music_settings_model.dart';
import '../common/models/shared_data_model.dart';
import '../common/models/side_bar_model.dart';
import '../common/widgets/song_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.storageAccess,
    required this.songList,
    super.key,
  });

  final bool storageAccess;
  final List<SongModel> songList;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  bool fileAccess = false;
  final OnAudioQuery audioQuery = OnAudioQuery();
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  AudioPlayerModel audioPlayerModel = AudioPlayerModel();
  List<SongModel> songs = [];

  Logger logger = Logger();

  SongModel? selectedSong;
  bool selectedSongLiked = false;
  bool tapOnSelectedSong = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    fileAccess = widget.storageAccess;
    songs = widget.songList;
    _tabController = TabController(length: SideBar.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    final deviceInfo = DeviceInfoPlugin();

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    Map<Permission, PermissionStatus> statuses = await [
      int.parse(androidInfo.version.release) > 12
          ? Permission.audio
          : Permission.storage,
    ].request();

    // Check the status of each permission
    if (statuses[Permission.audio] == PermissionStatus.granted ||
        statuses[Permission.storage] == PermissionStatus.granted) {
      logger.d('Storage permission granted');
      songs = await MusicSettings.instance.fetchAudioFiles();
      setState(() {
        fileAccess = true;
      });
    } else {
      logger.e('Storage permission not granted');
    }
  }

  late final requestPermissionScreen = Center(
    child: TextButton(
      onPressed: () async {
        await requestPermissions();
      },
      child: const Text('Allow'),
    ),
  );

  late final songListScreeen = SongListScreen(
    selectedSong: selectedSong,
    songs: songs,
  );

  late final likedSongsScreen = const Center(
    child: Text('Liked Songs'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music Player'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: fileAccess
              ? [
                  for (SideBar item in SideBar.values)
                    Tab(
                      text: item.getFieldName(),
                    )
                ]
              : [],
        ),
      ),
      body: fileAccess
          ? TabBarView(
              controller: _tabController,
              children: [
                songListScreeen,
                likedSongsScreen,
                const Center(
                  child: Text('Artists'),
                ),
                const Center(
                  child: Text('Albums'),
                ),
                const Center(
                  child: Text('Playlists'),
                ),
                const Center(
                  child: Text('none'),
                ),
              ],
            )
          : requestPermissionScreen,
    );
  }
}
