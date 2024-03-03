import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../common/models/audio_model.dart';
import '../common/models/shared_data_model.dart';
import '../common/widgets/selected_song_view.dart';

class PlayingSongScreen extends StatefulWidget {
  const PlayingSongScreen({
    required this.selectedSong,
    required this.songList,
    super.key,
  });

  final SongModel? selectedSong;
  final List<SongModel> songList;

  @override
  State<PlayingSongScreen> createState() => _PlayingSongScreenState();
}

class _PlayingSongScreenState extends State<PlayingSongScreen>
    with SingleTickerProviderStateMixin {
  Logger logger = Logger();
  Future<Uint8List>? _artworkFuture;
  bool shuffleEnable = true;
  bool loopEnable = true;
  late TabController _tabController;
  SongModel? selectedSong;

  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  AudioPlayerModel audioPlayerModel = AudioPlayerModel();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    selectedSong = widget.selectedSong;
    getArtwork(selectedSong?.id ?? 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Uint8List?> getArtwork(int songId) async {
    try {
      final Uint8List? artwork = await OnAudioQuery()
          .queryArtwork(songId, ArtworkType.AUDIO, size: 200);
      artwork != null ? _artworkFuture = Future.value(artwork) : null;
    } catch (e) {
      Logger().e('Error fetching artwork: $e');
    }
    setState(() {});
    return _artworkFuture;
  }

  String convertSecondsToMinutesAndSeconds(int seconds) {
    Duration duration = Duration(milliseconds: seconds);
    int minutes = duration.inMinutes;
    int remainingSeconds = duration.inSeconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> playWithShuffle() async {
    final shuffleSongs = List.from(widget.songList);
    shuffleSongs.shuffle();
    final selected = selectedSong != shuffleSongs.first
        ? shuffleSongs.first
        : shuffleSongs.last;
    audioPlayerModel.currentSong = selected;
    setState(() {
      selectedSong = selected;
      _artworkFuture = null;
    });
  }

  void enableDisableShuffle() {
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

  void enableDisableLoop() {
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

  Widget _buildCustomTab(String text) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => AudioPlayerModel(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 40, 8, 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      _buildCustomTab('Song'),
                      _buildCustomTab('Lyrics'),
                    ],
                    // indicatorSize: TabBarIndicatorSize.label,
                    indicatorWeight: 3.0,
                    tabAlignment: TabAlignment.center,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        SelectedSongView(
                          title: selectedSong?.title ?? 'Unknown',
                          artist: selectedSong?.artist ?? 'Unknown',
                          leadingIcon: const Icon(Icons.music_note),
                        ),

                        Expanded(
                          child: FutureBuilder(
                            future: _artworkFuture ??
                                getArtwork(selectedSong?.id ?? 0),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
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
                                      image: MemoryImage(
                                          snapshot.data as Uint8List),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        '${audioModel.currentPosition ~/ 60}:${(audioModel.currentPosition % 60).toInt().toString().padLeft(2, '0')}',
                                      ),
                                      Expanded(
                                        child: Slider(
                                          value: audioModel.currentPosition,
                                          min: 0,
                                          max: Duration(
                                            milliseconds:
                                                selectedSong?.duration ?? 0,
                                          ).inSeconds.toDouble(),
                                          onChanged: (value) async {
                                            audioModel.currentPosition = value;
                                            audioModel.seekTo(value.toDouble());
                                          },
                                        ),
                                      ),
                                      Text(
                                        convertSecondsToMinutesAndSeconds(
                                          selectedSong?.duration ?? 0,
                                        ),
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
                              onPressed: () {
                                enableDisableShuffle();
                              },
                            ),
                            IconButton(
                              icon: const ImageIcon(
                                AssetImage("assets/images/backward-track.png"),
                                color: Colors.black,
                                size: 24,
                              ),
                              onPressed: () {
                                if (shuffleEnable) {
                                  playWithShuffle();
                                }
                              },
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
                                          AssetImage(
                                              "assets/images/play-button.png"),
                                          color: Colors.black,
                                          size: 44,
                                        ),
                                  onPressed: () async {
                                    if (audioModel.currentPosition > 0.0) {
                                      audioModel.togglePlayPause();
                                    } else {
                                      await audioModel.playLocalMusic(
                                          widget.selectedSong?.data);
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
                                if (shuffleEnable) {
                                  playWithShuffle();
                                }
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
                              onPressed: () {
                                enableDisableLoop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Center(
                      child: Text('Lyrics'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
