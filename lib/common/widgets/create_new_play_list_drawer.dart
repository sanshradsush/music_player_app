import 'package:flutter/material.dart';

import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';

class CreatePlayListDrawer extends StatefulWidget {
  const CreatePlayListDrawer({
    super.key,
  });

  @override
  State createState() => _CreatePlayListDrawerState();
}

class _CreatePlayListDrawerState extends State<CreatePlayListDrawer> {
  MusicSettings musicSettings = MusicSettings.instance;
  final TextEditingController _playlistNameController = TextEditingController();
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey,
        ),
        boxShadow: const [
          BoxShadow(
            spreadRadius: 2,
            blurRadius: 1,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Create New Playlist',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _playlistNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Playlist Name',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String playlistName = _playlistNameController.text.trim();
                  if (playlistName.isNotEmpty) {
                    await musicSettings.createPlaylist(
                        playlistName: playlistName);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a playlist name'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: const Text('Create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
