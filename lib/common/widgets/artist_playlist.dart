import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_spin/common/screens/scaffold.dart';

import '../models/music_settings_model.dart';
import '../screens/song_list_screen.dart';
import 'app_bar_widget.dart';

class ArtistPlayList extends StatefulWidget {
  const ArtistPlayList({
    required this.artist,
    super.key,
  });

  final ArtistModel artist;

  @override
  State<ArtistPlayList> createState() => _ArtistPlayListState();
}

class _ArtistPlayListState extends State<ArtistPlayList> {
  final MusicSettings musicSettings = MusicSettings.instance;
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    fetchPlayListSongs();
  }

  Future<void> fetchPlayListSongs() async {
    songs = await musicSettings.fetchSongsfForArtist(
      artistName: widget.artist.artist,
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
              title: widget.artist.artist,
              leadingPress: () {
                Navigator.pop(context);
              },
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
