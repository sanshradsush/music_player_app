import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sound_spin/common/widgets/view_playlist.dart';
import '../models/music_settings_model.dart';
import '../widgets/leading_icon.dart';
import '../widgets/new_play_list_drawer.dart';
import '../models/shared_data_model.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({
    super.key,
  });

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  MusicSettings musicSettings = MusicSettings.instance;
  List<PlaylistModel> playlists = [];
  LocalSavingDataModel localDataModel = LocalSavingDataModel();
  OnAudioQuery audioQuery = OnAudioQuery();

  @override
  void initState() {
    super.initState();
    fetchPlaylists(); // Fetch playlists when the screen initializes
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Playlist(${playlists.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return const CreatePlayListDrawer();
                          },
                        ).then((_) async {
                          await fetchPlaylists();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const LeadingIcon(
                    icon: Icon(Icons.person),
                  ),
                  title: Text(playlists[index].playlist),
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewPlaylist(selectedPlayList: playlists[index]),
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