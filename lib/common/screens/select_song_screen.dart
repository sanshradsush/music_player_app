import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/music_settings_model.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/circular_check_box.dart';
import 'scaffold.dart';

class SelectSongScreen extends StatefulWidget {
  const SelectSongScreen({
    required this.playListId,
    super.key,
  });

  final int playListId;

  @override
  State createState() => _SelectSongScreenState();
}

class _SelectSongScreenState extends State<SelectSongScreen> {
  final MusicSettings musicSettings = MusicSettings.instance;
  List<SongModel> selectedSongs = [];
  List<SongModel> filteredSongsList = [];
  @override
  void initState() {
    super.initState();
    fetchFilteredList();
  }

  Future<void> fetchFilteredList() async {
    filteredSongsList = await musicSettings.filterSongsInPlaylist(
        playListId: widget.playListId);
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
            title: 'Select Songs',
            leadingPress: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSongsList.length,
              itemBuilder: (context, index) {
                final song = filteredSongsList[index];
                final isSelected = selectedSongs.contains(song);

                return GestureDetector(
                  child: ListTile(
                    leading: CircularCheckbox(
                      value: isSelected,
                    ),
                    title: Text(song.title),
                    subtitle: Text(song.artist ?? ''),
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedSongs.remove(song);
                      } else {
                        selectedSongs.add(song);
                      }
                    });
                  },
                );
              },
            ),
          ),
          if (selectedSongs.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: ElevatedButton(
                onPressed: () async {
                  // Call the function to add selected songs to the playlist
                  final success = await musicSettings.addSongsToPlaylist(
                    playlistId: widget.playListId,
                    songList: selectedSongs,
                  );

                  if (success) {
                    // If songs are added successfully, navigate back

                    // ignore: use_build_context_synchronously
                    Navigator.pop(context);
                  } else {
                    // Handle failure, such as showing a snackbar
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Failed to add songs to the playlist.'),
                    ));
                  }
                },
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
