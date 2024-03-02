import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../common/models/audio_model.dart';
import '../common/models/music_settings_model.dart';
import '../common/models/shared_data_model.dart';
import '../common/widgets/selected_song_view.dart';
import '../common/widgets/song_list_view.dart';
import 'playing_song_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.storageAccess,
    super.key,
  });
  final bool storageAccess;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool fileAccess = false;
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songs = [];

  Logger logger = Logger();

  SongModel? selectedSong;
  bool selectedSongLiked = false;
  bool tapOnSelectedSong = false;

  @override
  void initState() {
    super.initState();
    fileAccess = widget.storageAccess;
    if (fileAccess) {
      fetchAudioFiles();
    }
    updateSelectedSongFromLocalStorage();
  }

  Future<void> fetchAudioFiles() async {
    MusicSettings.instance.fetchAudioFiles().then(
          (value) => setState(
            () {
              songs = value;
            },
          ),
        );
  }

  Future<void> updateSelectedSongFromLocalStorage() async {
    final song = await LocalSavingDataModel().getCurrentPlayingSong();
    if (song != null) {
      final isLiked = await LocalSavingDataModel().checkForLikedSong(song);
      setState(() {
        selectedSong = song;
        selectedSongLiked = isLiked;
      });
    }
  }

  Future<void> requestPermissions() async {
    final deviceInfo = DeviceInfoPlugin();

    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    Map<Permission, PermissionStatus> statuses = await [
      int.parse(androidInfo.version.release) > 12
          ? Permission.audio
          : Permission.storage,
    ].request();

    // Check the status of each permission
    if (statuses[Permission.audio] == PermissionStatus.granted ||
        statuses[Permission.storage] == PermissionStatus.granted) {
      logger.d('Storage permission granted');
      await fetchAudioFiles();
      setState(() {
        fileAccess = true;
      });
    } else {
      logger.e('Storage permission not granted');
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

  Future<void> playMusic(SongModel? selectedSong) async {
    try {
      await AudioPlayerModel().playLocalMusic(selectedSong?.data ?? '');
    } catch (e) {
      logger.e('Error playing audio: $e');
    }
  }

  Future<void> playWithShuffle() async {
    final shuffleSongs = List.from(songs);
    shuffleSongs.shuffle();
    final selected = selectedSong != shuffleSongs.first
        ? shuffleSongs.first
        : shuffleSongs.last;
    await LocalSavingDataModel().updateCurrentPlayingSong(selected);
    final isLiked = await LocalSavingDataModel().checkForLikedSong(selected);
    setState(() {
      selectedSong = selected;
      selectedSongLiked = isLiked;
    });

    await playMusic(selectedSong);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    late final requestPermissionScreen = MaterialPage(
      child: Center(
        child: TextButton(
          onPressed: () async {
            await requestPermissions();
          },
          child: const Text('Allow'),
        ),
      ),
    );

    late final songListScreeen = MaterialPage(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Music Player'),
        ),
        body: Stack(
          children: [
            ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return SongListView(
                  title: songs[index].title,
                  artist: songs[index].artist ?? 'Unknown',
                  onTap: () async {
                    await LocalSavingDataModel()
                        .updateCurrentPlayingSong(songs[index]);
                    setState(() {
                      selectedSong = songs[index];
                    });
                    await playMusic(selectedSong);
                  },
                  leadingIcon: FutureBuilder(
                    future: getArtwork(songs[index].id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return CircleAvatar(
                          backgroundImage:
                              MemoryImage(snapshot.data as Uint8List),
                        );
                      } else {
                        return const Icon(Icons.music_note);
                      }
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                thickness: 0.1,
                color: Colors.grey,
              ),
              itemCount: songs.length,
            ),
            // Overlay Widget
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayingSongScreen(
                                selectedSong: selectedSong,
                                playNext: () async {
                                  playWithShuffle();
                                },
                                playPrevious: () async {
                                  playWithShuffle();
                                },
                              ),
                            ),
                          );
                        },
                        trailingIcon: IconButton(
                          onPressed: () async {
                            final isLiked = await LocalSavingDataModel()
                                .addLikedSong(selectedSong!);
                            if (isLiked) {
                              setState(() {
                                songs.add(selectedSong!);
                              });
                            }
                          },
                          icon: selectedSongLiked
                              ? const Icon(Icons.favorite)
                              : const Icon(Icons.favorite),
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
          ],
        ),
      ),
    );

    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) => route.didPop(result),
      pages: [
        songListScreeen,
        if (fileAccess == false) requestPermissionScreen,
      ],
    );
  }
}
