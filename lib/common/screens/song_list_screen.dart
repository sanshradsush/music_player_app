import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../widgets/playing_song_screen.dart';
import '../enums/song_options.dart';
import '../models/audio_model.dart';
import '../models/music_settings_model.dart';
import '../models/shared_data_model.dart';
import 'edit_song_detail.dart';
import 'song_bottom_sheet.dart';
import '../widgets/delete_widget.dart';
import '../widgets/leading_icon.dart';
import '../widgets/selected_song_view.dart';
import '../widgets/song_list_view.dart';
import 'song_info_screen.dart';

class SongListScreen extends StatefulWidget {
  const SongListScreen({
    required this.songList,
    this.isLikedTab = false,
    super.key,
  });

  final List<SongModel> songList;
  final bool isLikedTab;

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  AudioPlayerModel audioPlayerModel = AudioPlayerModel();
  LocalSavingDataModel localSavingDataModel = LocalSavingDataModel();
  MusicSettings musicSettings = MusicSettings.instance;
  OnAudioQuery audioQuery = OnAudioQuery();
  Logger logger = Logger();
  SongModel? selectedSong;
  bool selectedSongLiked = false;
  List<SongModel> songList = [];

  @override
  void initState() {
    super.initState();
    if (widget.isLikedTab) {
      songList = MusicSettings.likedSongsList;
    } else {
      updateSelectedSongFromLocalStorage();
    }
  }

  @override
  void didUpdateWidget(covariant SongListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    logger
        .d('Updating selected song from local storage --> ${widget.songList}');
    final song = await localSavingDataModel.getCurrentPlayingSong();
    if (song != null) {
      final isLiked = await localSavingDataModel.checkForLikedSong(song);
      logger
          .d('Updating selected song from local storage --> $song \n $isLiked');
      selectedSong = song;
      selectedSongLiked = isLiked;
    }

    songList = widget.songList;
    setState(() {});
  }

  void _showDeleteBottonSheet(BuildContext context, SongModel songModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DeleteWidget(
          title: 'Delete SONG',
          subtitle: 'Are you sure you want to delete ${songModel.title}?',
          onConfirm: () async {
            await musicSettings.deletePlaylist(
              playlistId: songModel.id,
            );
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSongInfoBottonSheet(BuildContext context, SongModel songModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SongInfoScreen(
          songModel: songModel,
          onEdit: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditSongDetailsScreen(
                  songModel: songModel,
                  onSaved: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSongtMoreBottomSheet(BuildContext context, SongModel songModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SongBottomList(
          songModel: songModel,
          onTap: (option) async {
            switch (option) {
              case SongOptions.info:
                Navigator.pop(context);
                _showSongInfoBottonSheet(context, songModel);
                break;
              case SongOptions.rename:
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditSongDetailsScreen(
                      songModel: songModel,
                      onSaved: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
                break;
              case SongOptions.delete:
                Navigator.pop(context);
                _showDeleteBottonSheet(context, songModel);
                break;
              default:
                break;
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudioPlayerModel(),
      child: Stack(
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
                      } else {
                        return const LeadingIcon(icon: Icon(Icons.music_note));
                      }
                    },
                  ),
                  onTapOfMoreIcon: () {
                    _showSongtMoreBottomSheet(context, songList[index]);
                  });
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
                          ).then((currentSong) async {
                            logger.d(
                                'Current song: ${MusicSettings.selectedSong}');

                            selectedSong = MusicSettings.selectedSong;
                            selectedSongLiked = await localSavingDataModel
                                .checkForLikedSong(selectedSong!);
                            // fetchSongs();
                          });
                        },
                        trailingIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (selectedSongLiked) {
                                  final unliked = await localSavingDataModel
                                      .removeLikedSong(selectedSong!);
                                  if (unliked) {
                                    MusicSettings.likedSongsList =
                                        await localSavingDataModel
                                            .getLikedSongs();
                                    if (widget.isLikedTab) {
                                      songList = MusicSettings.likedSongsList;
                                    }
                                    selectedSongLiked = false;
                                    setState(() {});
                                  }
                                } else {
                                  final isLiked = await localSavingDataModel
                                      .addLikedSong(selectedSong!);
                                  if (isLiked) {
                                    MusicSettings.likedSongsList =
                                        await localSavingDataModel
                                            .getLikedSongs();
                                    if (widget.isLikedTab) {
                                      songList = MusicSettings.likedSongsList;
                                    }
                                    selectedSongLiked = true;
                                    setState(() {});
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
      ),
    );
  }
}
