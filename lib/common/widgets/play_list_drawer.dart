import 'package:flutter/material.dart';

import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';

class PlayListDrawer extends StatefulWidget {
  const PlayListDrawer({
    required this.title,
    this.intialText,
    required this.onSaved,
    required this.onCancel,
    super.key,
  });

  final String title;
  final String? intialText;
  final Function(String) onSaved;
  final VoidCallback onCancel;

  @override
  State createState() => _PlayListDrawerState();
}

class _PlayListDrawerState extends State<PlayListDrawer> {
  MusicSettings musicSettings = MusicSettings.instance;
  TextEditingController? _playlistNameController;
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();

  @override
  void dispose() {
    _playlistNameController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _playlistNameController = TextEditingController(text: widget.intialText);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.white,
        boxShadow: [
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
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _playlistNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                hintText: 'Enter playlist name',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => widget.onCancel(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => widget.onSaved(
                  (_playlistNameController?.text ?? '').trim(),
                ),
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
