import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../common/models/shared_data_model.dart';
import '../common/models/side_bar_model.dart';
import '../common/widgets/album_screen.dart';
import '../common/widgets/artists_screen.dart';
import '../common/widgets/playlist_screen.dart';
import '../common/widgets/song_list_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  Logger logger = Logger();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: SideBar.values.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late final songListScreeen = const SongListScreen();

  late final likedSongsScreen = const SongListScreen(
    likedTab: true,
  );

  late final playListScreen = const PlayListScreen();

  late final artistsScreen = const ArtistsScreen();
  late final albumScreen = const AlbumScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music Player'),
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding: EdgeInsets.zero,
          isScrollable: true,
          tabs: [
            for (SideBar item in SideBar.values)
              Tab(
                text: item.getFieldName(),
              )
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          songListScreeen,
          likedSongsScreen,
          playListScreen,
          const Center(
            child: Text('Folders'),
          ),
          albumScreen,
          artistsScreen
        ],
      ),
    );
  }
}
