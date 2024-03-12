import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/music_settings_model.dart';
import '../screens/song_list_screen.dart';
import 'app_bar_widget.dart';
import '../screens/scaffold.dart';

class AlbumPlayList extends StatefulWidget {
  const AlbumPlayList({
    required this.album,
    super.key,
  });

  final AlbumModel album;

  @override
  State<AlbumPlayList> createState() => _AlbumPlayListState();
}

class _AlbumPlayListState extends State<AlbumPlayList> {
  final MusicSettings musicSettings = MusicSettings.instance;
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    fetchPlayListSongs();
  }

  Future<void> fetchPlayListSongs() async {
    songs = await musicSettings.fetchSongsForAlbum(
      albumName: widget.album.album,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBarWidget(
              leadingIcon: const Center(
                child: Icon(Icons.abc),
              ),
              title: widget.album.album,
              leadingPress: () {
                Navigator.pop(context);
              },
              subtitle: '${widget.album.artist} | ${songs.length} song',
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Songs (${songs.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: SongListScreen(
                songList: songs,
              ),
            )
          ],
        ),
      ),
    );
  }
}
