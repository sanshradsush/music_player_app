import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../common/models/audio_model.dart';
import '../common/models/music_settings_model.dart';
import '../common/models/shared_data_model.dart';
import '../common/models/side_bar_model.dart';
import '../common/widgets/song_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.songList,
    super.key,
  });

  final List<SongModel> songList;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final OnAudioQuery audioQuery = OnAudioQuery();
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  AudioPlayerModel audioPlayerModel = AudioPlayerModel();
  Logger logger = Logger();
  List<SongModel> songs = [];
  SongModel? selectedSong;
  bool selectedSongLiked = false;
  bool tapOnSelectedSong = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    songs = widget.songList;
    _tabController = TabController(length: SideBar.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late final songListScreeen = SongListScreen(
    selectedSong: selectedSong,
  );

  late final likedSongsScreen = SongListScreen(
    selectedSong: selectedSong,
    likedTab: true,
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
              tabs: [
                for (SideBar item in SideBar.values)
                  Tab(
                    text: item.getFieldName(),
                  )
              ],
              onTap: (index) async {
                logger.i('Tab index: $index');
                if (index == 0) {
                  songs = await MusicSettings.instance.fetchAudioFiles();
                } else if (index == 1) {
                  songs = await localSavingDataModel.getLikedSongs();
                  logger.e('Liked songs: $songs');
                }

                setState(() {});
              }),
        ),
        body: TabBarView(
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
        ));
  }
}
