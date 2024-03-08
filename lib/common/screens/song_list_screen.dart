import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../widgets/playing_song_screen.dart';
import '../models/audio_model.dart';
import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';
import '../widgets/leading_icon.dart';
import '../widgets/selected_song_view.dart';
import '../widgets/song_list_view.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({
    this.likedTab = false,
    super.key,
  });

  final bool likedTab;

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  AudioPlayerModel audioPlayerModel = AudioPlayerModel();
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  OnAudioQuery audioQuery = OnAudioQuery();
  Logger logger = Logger();
  SongModel? selectedSong;
  bool selectedSongLiked = false;
  List<SongModel> songList = [];

  @override
  void initState() {
    super.initState();
    fetchSongs();
    updateSelectedSongFromLocalStorage();
  }

  Future<void> fetchSongs() async {
    if (widget.likedTab) {
      final List<SongModel> likedSongs =
          await localSavingDataModel.getLikedSongs();

      setState(() {
        songList = likedSongs;
      });
    } else {
      final List<SongModel> songs = await audioQuery.querySongs();
      setState(() {
        songList = songs;
      });
    }
  }

  Future<Uint8List?> getArtwork(int songId) async {
    try {
      final Uint8List? artwork =
          await audioQuery.queryArtwork(songId, ArtworkType.AUDIO, size: 200);
      return artwork;
    } catch (e) {
      logger.e('Error fetching artwork: $e');
      return null;
    }
  }

  Future<void> updateSelectedSongFromLocalStorage() async {
    logger.d('Updating selected song from local storage');
    final song = await localSavingDataModel.getCurrentPlayingSong();
    if (song != null) {
      final isLiked = await localSavingDataModel.checkForLikedSong(song);
      logger
          .d('Updating selected song from local storage --> $song \n $isLiked');
      setState(() {
        selectedSong = song;
        selectedSongLiked = isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return SongListView(
              title: songList[index].title,
              artist: songList[index].artist ?? 'Unknown',
              onTap: () async {
                audioPlayerModel.currentSong = songList[index];
                selectedSongLiked = await localSavingDataModel
                    .checkForLikedSong(songList[index]);
                selectedSong = songList[index];
                logger.d('Selected song: $selectedSong');
                setState(() {});
              },
              leadingIcon: FutureBuilder(
                future: getArtwork(songList[index].id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return LeadingIcon(
                      icon: Image.memory(
                        snapshot.data
                            as Uint8List, // Adjust the BoxFit as needed
                      ),
                    );

                    // CircleAvatar(
                    //   backgroundImage: MemoryImage(snapshot.data as Uint8List),
                    // );
                  } else {
                    return const LeadingIcon(icon: Icon(Icons.music_note));
                  }
                },
              ),
            );
          },
          itemCount: songList.length,
        ),
        if (selectedSong != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.yellow.shade200,
                    Colors.pink.shade200,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
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
              child: Center(
                child: Consumer<AudioPlayerModel>(
                  builder: (context, audioModel, child) {
                    return SelectedSongView(
                      artist: selectedSong?.artist ?? 'Unknown',
                      title: selectedSong?.title ?? 'Unknown',
                      onTap: () {
                        showModalBottomSheet<SongModel>(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return PlayingSongScreen(
                              selectedSong: selectedSong,
                              songList: songList,
                            );
                          },
                        ).then((currentSong) {
                          logger
                              .d('Current song: ${MusicSettings.selectedSong}');
                          setState(() {
                            selectedSong = MusicSettings.selectedSong;
                          });
                        });
                      },
                      trailingIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (selectedSongLiked) {
                                final isUnliked = await localSavingDataModel
                                    .removeLikedSong(selectedSong!);
                                if (isUnliked) {
                                  selectedSongLiked = false;
                                  await fetchSongs();
                                }
                              } else {
                                final isLiked = await localSavingDataModel
                                    .addLikedSong(selectedSong!);
                                if (isLiked) {
                                  selectedSongLiked = true;
                                  await fetchSongs();
                                }
                              }
                            },
                            icon: selectedSongLiked
                                ? const Icon(
                                    Icons.favorite,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.favorite_border),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (audioModel.currentPosition > 0.0) {
                                audioModel.togglePlayPause();
                              } else {
                                await audioModel
                                    .playLocalMusic(selectedSong?.data);
                              }
                            },
                            icon: audioModel.isPlaying
                                ? const Icon(
                                    Icons.pause,
                                  )
                                : const Icon(Icons.play_arrow_sharp),
                          ),
                        ],
                      ),
                      leadingIcon: FutureBuilder(
                        future: getArtwork(selectedSong?.id ?? 0),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data != null) {
                            return CircleAvatar(
                              backgroundImage:
                                  MemoryImage(snapshot.data as Uint8List),
                            );
                          } else {
                            return const CircleAvatar(
                              backgroundColor: Colors.grey,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
