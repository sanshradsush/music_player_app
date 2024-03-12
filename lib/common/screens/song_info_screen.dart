import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongInfoScreen extends StatelessWidget {
  const SongInfoScreen({
    required this.songModel,
    required this.onEdit,
    super.key,
  });

  final SongModel songModel;
  final VoidCallback onEdit;

  String convertSecondsToMinutesAndSeconds(int seconds) {
    Duration duration = Duration(milliseconds: seconds);
    int minutes = duration.inMinutes;
    int remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              Text('Title:\t\t ${songModel.title}'),
              const SizedBox(height: 10),
              Text('Artist:\t\t ${songModel.artist ?? 'Unknown'}'),
              const SizedBox(height: 10),
              Text('Album:\t\t ${songModel.album ?? 'Unknown'}'),
              const SizedBox(height: 10),
              Text(
                'Duration:\t\t ${convertSecondsToMinutesAndSeconds(songModel.duration ?? 0)}',
              ),
              const SizedBox(height: 10),
              Text('Size:\t\t ${(songModel.size / (2 * 1024))} MB'),
              const SizedBox(height: 10),
              Text('Genre:\t\t ${songModel.genre ?? 'Unknown'}'),
              const SizedBox(height: 10),
              Text('Location:\t\t ${songModel.data}'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: onEdit,
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
