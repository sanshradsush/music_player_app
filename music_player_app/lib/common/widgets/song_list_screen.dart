import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../widgets/playing_song_screen.dart';
import '../models/audio_model.dart';
import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';
import 'selected_song_view.dart';
import 'song_list_view.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({
    required this.selectedSong,
    required this.songs,
    super.key,
  });

  final SongModel? selectedSong;
  final List<SongModel> songs;

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
    selectedSong = widget.selectedSong;
    songList = widget.songs;
    updateSelectedSongFromLocalStorage();
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
        ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return SongListView(
              title: songList[index].title,
              artist: songList[index].artist ?? 'Unknown',
              onTap: () async {
                audioPlayerModel.currentSong = songList[index];
                setState(() {
                  selectedSong = songList[index];
                });
              },
              leadingIcon: FutureBuilder(
                future: getArtwork(songList[index].id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return CircleAvatar(
                      backgroundImage: MemoryImage(snapshot.data as Uint8List),
                    );
                  } else {
                    return const Icon(Icons.music_note);
                  }
                },
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(
            thickness: 0.1,
            color: Colors.grey,
          ),
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
                        logger.d('Current song: ${MusicSettings.selectedSong}');
                        setState(() {
                          selectedSong = MusicSettings.selectedSong;
                        });
                      });
                    },
                    trailingIcon: IconButton(
                      onPressed: () async {
                        if (selectedSongLiked) {
                          final isUnliked = await localSavingDataModel
                              .removeLikedSong(selectedSong!);
                          if (isUnliked) {
                            setState(() {
                              selectedSongLiked = false;
                              songList.remove(selectedSong!);
                            });
                          }
                        } else {
                          final isLiked = await localSavingDataModel
                              .addLikedSong(selectedSong!);
                          if (isLiked) {
                            setState(() {
                              selectedSongLiked = true;
                              songList.add(selectedSong!);
                            });
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
                    leadingIcon: FutureBuilder(
                      future: getArtwork(widget.selectedSong?.id ?? 0),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
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
      ],
    );
  }
}
