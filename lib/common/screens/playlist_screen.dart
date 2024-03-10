import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../enums/song_options.dart';
import '../models/music_settings_model.dart';
import '../models/play_list_bottom_sheet.dart';
import '../widgets/delete_widget.dart';
import '../widgets/leading_icon.dart';
import '../widgets/play_list_drawer.dart';
import '../models/shared_data_model.dart';
import '../widgets/view_playlist.dart';

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

  // Method to show the bottom sheet

  void _showPlayListRenameBottomSheet(
      BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PlayListDrawer(
          title: 'Rename',
          intialText: playlist.playlist,
          onSaved: (newName) async {
            if (newName.isNotEmpty) {
              final status = await musicSettings.renamePlaylist(
                  playlistId: playlist.id, newName: newName);
              if (status) {
                await fetchPlaylists();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a playlist name'),
                ),
              );
            }
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showPlayListMoreBottomSheet(
      BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PlayListBottomSheet(
          playListName: playlist.playlist,
          number: playlist.numOfSongs,
          onTap: (option) async {
            switch (option) {
              case SongOptions.rename:
                Navigator.pop(context);
                _showPlayListRenameBottomSheet(context, playlist);
                break;
              case SongOptions.delete:
                Navigator.pop(context);
                _showDeleteBottonSheet(context, playlist);
                break;
              default:
                break;
            }
          },
        );
      },
    );
  }

  void _showDeleteBottonSheet(BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DeleteWidget(
          title: 'Delete Playlist',
          subtitle:
              'Are you sure you want to delete playlist ${playlist.playlist}?',
          onConfirm: () async {
            await musicSettings.deletePlaylist(
              playlistId: playlist.id,
            );
            await fetchPlaylists();
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
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
                            return PlayListDrawer(
                              title: 'Create new playlist',
                              onSaved: (newName) async {
                                if (newName.isNotEmpty) {
                                  await musicSettings.createPlaylist(
                                      playlistName: newName);
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please enter a playlist name'),
                                    ),
                                  );
                                }
                              },
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
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
                          builder: (context) => ViewPlaylist(
                            selectedPlayList: playlists[index],
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () async {
                        _showPlayListMoreBottomSheet(context, playlists[index]);
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
