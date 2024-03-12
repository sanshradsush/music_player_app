import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../enums/song_options.dart';

class SongBottomList extends StatelessWidget {
  const SongBottomList({
    required this.songModel,
    required this.onTap,
    super.key,
  });
  final SongModel songModel;
  final Function(SongOptions) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(songModel.title),
          subtitle: Text(songModel.artist ?? 'Unknown'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  onTap(SongOptions.info);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  onTap(SongOptions.share);
                },
              ),
            ],
          ),
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
          title: const Text('Edit tags'),
          onTap: () {
            onTap(SongOptions.rename);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Delete from device'),
          onTap: () {
            onTap(SongOptions.delete);
          },
        ),
      ],
    );
  }
}
