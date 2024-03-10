import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/music_settings_model.dart';
import 'app_bar_widget.dart';
import '../screens/scaffold.dart';
import 'leading_icon.dart';

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
              child: ListView.builder(
                // padding: const EdgeInsets.fromLTRB(25.0, 0, 8.0, 8.0),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
                    leading: const LeadingIcon(
                      icon: Icon(Icons.music_note),
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artist ?? ''),
                    onTap: () {
                      // Add logic to handle song tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
