import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/music_settings_model.dart';

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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.yellow.shade200,
              Colors.pink.shade200,
            ],
          ),
        ),
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Add some space between the icon and playlist name
                  Text(
                    widget.album.album,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  25.0, 0, 8.0, 8.0), // Adjust the left padding here
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Songs (${songs.length})',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(25.0, 0, 8.0, 8.0),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return ListTile(
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
