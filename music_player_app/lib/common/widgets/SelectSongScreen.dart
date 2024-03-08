import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';

class SelectSongScreen extends StatefulWidget {
  const SelectSongScreen({
    required this.playListId,
    Key? key,
  }) : super(key: key);

  final int playListId;

  @override
  _SelectSongScreenState createState() => _SelectSongScreenState();
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
      filteredSongsList = await musicSettings.filterSongsInPlaylist(widget.playListId);
      setState(() {
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Songs'),
      ),
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
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredSongsList.length,
                itemBuilder: (context, index) {
                  final song = filteredSongsList[index];
                  final isSelected = selectedSongs.contains(song);

                  return CheckboxListTile(
                    title: Text(song.title),
                    subtitle: Text(song.artist ?? ''),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value != null && value) {
                          selectedSongs.add(song);
                        } else {
                          selectedSongs.remove(song);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            if (selectedSongs.isNotEmpty)
              SizedBox(
                height: 60, // Adjust the height as needed
                child: ElevatedButton(
                  onPressed: () {
                    _addSelectedSongsToPlaylist();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSelectedSongsToPlaylist() async {
    // Call the function to add selected songs to the playlist
    final success = await musicSettings.addSongsToPlaylist(widget.playListId, selectedSongs);

    if (success) {
      // If songs are added successfully, navigate back
      Navigator.pop(context);
    } else {
      // Handle failure, such as showing a snackbar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add songs to the playlist.'),
      ));
    }
  }
}
