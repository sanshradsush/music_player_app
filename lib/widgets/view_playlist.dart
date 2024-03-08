import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../common/models/music_settings_model.dart';
import '../common/widgets/select_song_screen.dart';

class ViewPlaylist extends StatefulWidget {
  const ViewPlaylist({super.key, required this.selectedPlayList});

  final PlaylistModel selectedPlayList;

  @override
  State<ViewPlaylist> createState() => _ViewPlaylistState();
}

class _ViewPlaylistState extends State<ViewPlaylist> {
  final MusicSettings musicSettings = MusicSettings.instance;
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    fetchPlayListSongs();
  }

  Future<void> fetchPlayListSongs() async {
    songs = await musicSettings.fetchSongsFromPlayList(
      playlistId: widget.selectedPlayList.id,
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
                    widget.selectedPlayList.playlist,
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
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSongScreen(
                            playListId: widget.selectedPlayList.id,
                          ),
                        ),
                      ).then((_) async {
                        await fetchPlayListSongs();
                      });
                    },
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
