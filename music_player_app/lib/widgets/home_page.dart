import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../common/models/shared_data_model.dart';
import '../common/models/side_bar_model.dart';
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
          ),
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
