import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../common/models/audio_model.dart';
import '../common/widgets/selected_song_view.dart';

class PlayingSongScreen extends StatefulWidget {
  const PlayingSongScreen({
    required this.selectedSong,
    required this.playNext,
    required this.playPrevious,
    super.key,
  });

  final SongModel? selectedSong;
  final VoidCallback playNext;
  final VoidCallback playPrevious;

  @override
  State<PlayingSongScreen> createState() => _PlayingSongScreenState();
}

class _PlayingSongScreenState extends State<PlayingSongScreen> {
  bool shuffleEnable = true;
  bool loopEnable = true;
  
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<Uint8List?> getArtwork(int songId) async {
    try {
      final Uint8List? artwork = await OnAudioQuery()
          .queryArtwork(songId, ArtworkType.AUDIO, size: 200);
      return artwork;
    } catch (e) {
      Logger().e('Error fetching artwork: $e');
      return null;
    }
  }

  String convertSecondsToMinutesAndSeconds(int seconds) {
    Duration duration = Duration(milliseconds: seconds);
    int minutes = duration.inMinutes;
    int remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> enableDisableShuffle() async {
    setState(() {
      if (shuffleEnable == true) {
        shuffleEnable = false;
        loopEnable = true;
      } else {
        shuffleEnable = true;
        loopEnable = false;
      }
    });
  }

  Future<void> enableDisableLoop() async {
    setState(() {
      if (loopEnable == true) {
        loopEnable = false;
        shuffleEnable = true;
      } else {
        loopEnable = true;
        shuffleEnable = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // convertSecondsToMinutesAndSeconds(widget.selectedSong?.duration ?? 0);
    return ChangeNotifierProvider(
      create: (context) => AudioPlayerModel(),
      child: Column(
        children: [
          SelectedSongView(
            title: widget.selectedSong?.title ?? 'Unknown',
            artist: widget.selectedSong?.artist ?? 'Unknown',
            leadingIcon: const Icon(Icons.music_note),
          ),
          Expanded(
            child: FutureBuilder(
              future: getArtwork(widget.selectedSong?.id ?? 0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      // Adjust the radius as needed
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
          ),
          const SizedBox(height: 20),
          // Progress bar
          Consumer<AudioPlayerModel>(
            builder: (context, audioModel, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${audioModel.currentPosition ~/ 60}:${(audioModel.currentPosition % 60).toInt().toString().padLeft(2, '0')}',
                        ),
                        Expanded(
                          child: Slider(
                            value: audioModel.currentPosition,
                            min: 0,
                            max: Duration(
                              milliseconds: widget.selectedSong?.duration ?? 0,
                            ).inSeconds.toDouble(),
                            onChanged: (value) async {
                              audioModel.currentPosition = value;
                              audioModel.seekTo(value.toDouble());
                            },
                          ),
                        ),
                        Text(
                          convertSecondsToMinutesAndSeconds(
                              widget.selectedSong?.duration ?? 0),
                        ),
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
                icon: shuffleEnable
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        child: ImageIcon(
                          AssetImage("assets/images/arrow.png"),
                          color: Colors.black,
                          size: 20,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        child: ImageIcon(
                          AssetImage("assets/images/arrow.png"),
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                onPressed: () async {
                  await enableDisableShuffle();
                },
              ),
              IconButton(
                icon: const ImageIcon(
                  AssetImage("assets/images/backward-track.png"),
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () {},
              ),
              Consumer<AudioPlayerModel>(
                builder: (context, audioModel, child) {
                  return IconButton(
                    icon: audioModel.isPlaying
                        ? const ImageIcon(
                            AssetImage("assets/images/pause.png"),
                            color: Colors.black,
                            size: 44,
                          )
                        : const ImageIcon(
                            AssetImage("assets/images/play-button.png"),
                            color: Colors.black,
                            size: 44,
                          ),
                    onPressed: () async {
                      if (audioModel.currentPosition > 0.0) {
                        audioModel.togglePlayPause();
                      } else {
                        await audioModel
                            .playLocalMusic(widget.selectedSong?.data);
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const ImageIcon(
                  AssetImage("assets/images/next.png"),
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {});
                },
              ),
              IconButton(
                icon: loopEnable
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        child: ImageIcon(
                          AssetImage("assets/images/loop.png"),
                          color: Colors.black,
                          size: 20,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 16.0),
                        child: ImageIcon(
                          AssetImage("assets/images/loop.png"),
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                onPressed: () async {
                  await enableDisableLoop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
