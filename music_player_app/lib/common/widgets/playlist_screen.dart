import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_spin/widgets/view_playlist.dart';
import '../models/music_settings_model.dart';
import 'create_new_play_list_drawer.dart';
import '../models/shared_data_model.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({Key? key});

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  MusicSettings musicSettings = MusicSettings.instance;
  List<PlaylistModel> playlists = [];
  LocalSavingDataModel localDataModel = LocalSavingDataModel();
  List<SongModel> allSongsList = [];
  OnAudioQuery audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    fetchSongs();
    fetchPlaylists(); // Fetch playlists when the screen initializes
  }

  Future<void> fetchSongs() async {
    final List<SongModel> songs = await audioQuery.querySongs();
    setState(() {
      allSongsList = songs;
    });
  }

  // Method to fetch playlists
  Future<void> fetchPlaylists() async {
    final fetchedPlaylists = await musicSettings.fetchPlaylists();
    setState(() {
      playlists = fetchedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Playlist(${playlists.length})',
                  style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CreatePlayListDrawer();
                        },
                      ).then((_) async {
                        await fetchPlaylists();

                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      setState(() {
                        // count--;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(playlists[index].playlist),
                  onTap: () async {
                    // List<SongModel> songs =
                    //    await musicSettings.fetchSongsFromPlayList(playlists[index].playlist);
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return ViewPlaylist(
                            selectedPlayList: playlists[index]);
                      },
                    ).then((currentSong) {
                      setState(() {});
                    });
                  },
                  // Add functionality for each playlist item if needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
