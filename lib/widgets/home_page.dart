import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../common/models/shared_data_model.dart';
import '../common/models/side_bar_model.dart';
import '../common/screens/album_screen.dart';
import '../common/screens/artists_screen.dart';
import '../common/screens/playlist_screen.dart';
import '../common/screens/scaffold.dart';
import '../common/screens/song_list_screen.dart';

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
    return ScaffoldScreen(
      appBar: AppBar(
        backgroundColor: Colors.yellow.shade200,
        title: const Text('Music Player'),
        bottom: TabBar(
          dividerColor: Colors.black,
          labelColor: Colors.black,
          labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              fontSize: 16,
          ),
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (SideBar item in SideBar.values)
              Tab(
                text: item.getFieldName(),
              )
          ],
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          songListScreeen,
          likedSongsScreen,
          playListScreen,
          const Center(
            child: Text('Folders'),
          ),
          albumScreen,
          artistsScreen,
        ],
      ),
    );
  }
}
