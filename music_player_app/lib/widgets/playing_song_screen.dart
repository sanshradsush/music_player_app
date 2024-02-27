import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../common/models/audio_model.dart';
import '../common/widgets/selected_song_view.dart';

class PlayingSongScreen extends StatefulWidget {
  const PlayingSongScreen({
    required this.selectedSong,
    super.key,
  });

  final SongModel? selectedSong;

  @override
  State<PlayingSongScreen> createState() => _PlayingSongScreenState();
}

class _PlayingSongScreenState extends State<PlayingSongScreen> {
  Future<Uint8List?> getArtwork(int songId) async {
    try {
      final Uint8List? artwork = await OnAudioQuery()
          .queryArtwork(songId, ArtworkType.AUDIO, size: 200);
      return artwork;
    } catch (e) {
      print('Error fetching artwork: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioPlayerModel(),
      child: Column(
        children: [
          SelectedSongView(
            title: widget.selectedSong?.title ?? 'Unknown',
            artist: widget.selectedSong?.artist ?? 'Unknown',
            leadingIcon: const Icon(Icons.music_note),
            trailingIcon: const Icon(Icons.play_arrow),
          ),
          FutureBuilder(
            future: getArtwork(widget.selectedSong?.id ?? 0),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return Container(
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Adjust the radius as needed
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data as Uint8List),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              } else {
                return const Icon(Icons.music_note);
              }
            },
          ),
          const SizedBox(height: 20),
          // Progress bar
          Consumer<AudioPlayerModel>(
            builder: (context, audioModel, child) {
              return Column(
                children: [
                  Slider(
                    value: audioModel.currentPosition,
                    min: 0,
                    max: audioModel.totalDuration,
                    onChanged: (value) {
                      audioModel.seekTo(value);
                    },
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text((audioModel.currentPosition/60).toStringAsFixed(2)),
                        Text((audioModel.totalDuration/60).toStringAsFixed(2)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),
              Consumer<AudioPlayerModel>(
                builder: (context, audioModel, child) {
                  return IconButton(
                    icon: audioModel.isPlaying
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                    onPressed: () {
                      audioModel.togglePlayPause();
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  setState(() {
                    
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
