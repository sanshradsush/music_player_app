import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/music_settings_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/circular_check_box.dart';
import 'scaffold.dart';

class DeletePlaylistScreen extends StatefulWidget {
  const DeletePlaylistScreen({
    super.key,
  });

  @override
  State createState() => _DeletePlaylistScreenState();
}

class _DeletePlaylistScreenState extends State<DeletePlaylistScreen> {
  final MusicSettings musicSettings = MusicSettings.instance;
  List<PlaylistModel> selectedPlaylists = [];
  List<PlaylistModel> fetchedPlaylistsList = [];
  late int playlistId;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
  }

  Future<void> fetchPlaylists() async {
    fetchedPlaylistsList = await musicSettings.fetchPlaylists();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      child: Column(
        children: [
          AppBarWidget(
            leadingIcon: const Center(
              child: Icon(Icons.abc),
            ),
            title: 'Delete playlists',
            leadingPress: () {
              Navigator.pop(context);
            },
          ),
          fetchedPlaylistsList.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: selectAll,
                      onChanged: (value) {
                        setState(() {
                          selectAll = value!;
                          if (selectAll) {
                            selectedPlaylists = List.from(fetchedPlaylistsList);
                          } else {
                            selectedPlaylists.clear();
                          }
                        });
                      },
                    ),
                    title: const Text('Select All'),
                  ),
                )
              : const SizedBox(), // If no playlists, render an empty SizedBox
          fetchedPlaylistsList.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'Please create a playlist.',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.zero, // Remove padding from ListView.builder
                    itemCount: fetchedPlaylistsList.length,
                    itemBuilder: (context, index) {
                      final playlist = fetchedPlaylistsList[index];
                      final isSelected = selectedPlaylists.contains(playlist);
                      playlistId = fetchedPlaylistsList[index].id;

                      return GestureDetector(
                        child: ListTile(
                          leading: CircularCheckbox(
                            value: isSelected,
                          ),
                          title: Text(playlist.playlist),
                        ),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedPlaylists.remove(playlist);
                            } else {
                              selectedPlaylists.add(playlist);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
          if (fetchedPlaylistsList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 0, 16.0, 20.0), // Adjust padding as needed
              child: SizedBox(
                width: double.infinity,
                height: 60, // Adjust the height as needed
                child: ElevatedButton(
                  onPressed: () async {
                    // Call the function to delete selected playlists
                    final success = await musicSettings.deletePlaylists(
                      playlistList: selectedPlaylists,
                    );
                    if (success) {
                      // If playlists are deleted successfully, navigate back
                      Navigator.pop(context);
                    } else {
                      // Handle failure, such as showing a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Failed to delete playlists.'),
                      ));
                    }
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
