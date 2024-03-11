import 'package:flutter/material.dart';

import '../enums/song_options.dart';

class PlayListBottomSheet extends StatelessWidget {
  const PlayListBottomSheet({
    required this.playListName,
    required this.number,
    required this.onTap,
    super.key,
  });
  final String playListName;
  final int number;
  final Function(SongOptions) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(playListName),
          subtitle: Text('$number songs'),
        ),
        const Divider(
          thickness: 0.5,
        ),
        ListTile(
          leading: const Icon(Icons.play_circle_outline),
          title: const Text('Play next'),
          onTap: () {
            onTap(SongOptions.playNext);
          },
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Add to queue'),
          onTap: () {
            onTap(SongOptions.addToQueue);
          },
        ),
        ListTile(
          leading: const Icon(Icons.add_to_home_screen),
          title: const Text('Add to playlist'),
          onTap: () {
            onTap(SongOptions.addToPlaylist);
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Rename'),
          onTap: () {
            onTap(SongOptions.rename);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete'),
          onTap: () {
            onTap(SongOptions.delete);
          },
        ),
      ],
    );
  }
}
