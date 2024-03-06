import 'package:flutter/material.dart';

import 'create_new_play_list_drawer.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({super.key});

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playlist($count)',
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
                  ).then((currentSong) {
                    // logger
                    //     .d('Current song: ${MusicSettings.selectedSong}');
                    // setState(() {
                    //   selectedSong = MusicSettings.selectedSong;
                    // });
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
    );
  }
}
