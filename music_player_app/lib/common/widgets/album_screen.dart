import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/music_settings_model.dart';
import 'album_playlist.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({
    super.key,
  });

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  MusicSettings musicSettings = MusicSettings.instance;
  List<AlbumModel> albums = [];

  @override
  void initState() {
    super.initState();
    fetchAlbums();
  }

  Future<void> fetchAlbums() async {
    final fetchedPlaylists = await musicSettings.fetchAlbums();
    setState(() {
      albums = fetchedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Albums(${albums.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: albums.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(albums[index].album),
                  subtitle: Text('${albums[index].artist}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumPlayList(
                          album: albums[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
