import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../common/models/audio_model.dart';
import '../common/widgets/selected_song_view.dart';
import '../common/widgets/song_list_view.dart';
import 'left_menu_drawer.dart';
import 'playing_song_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool fileAccess = false;
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songs = [];

  Logger logger = Logger();

  SongModel? selectedSong;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // await requestPermissions();
    checkAndRequestPermissions();
  }

  // Future<void> requestPermissions() async {
  //   // Request storage permissions
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission
  //         .storage, // For READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE
  //     // Add more permissions as needed
  //   ].request();

  //   // Check the status of each permission
  //   if (statuses[Permission.storage] != PermissionStatus.granted) {
  //     // Handle the case when the storage permission is not granted
  //     print('Storage permission not granted');
  //   } else {
  //     // The storage permission is granted, you can proceed with file and media access
  //     print('Storage permission granted');
  //   }
  // }

  void checkAndRequestPermissions() async {
    // The param 'retryRequest' is false, by default.
    final hasPermission = await audioQuery.permissionsRequest(
      retryRequest: true,
    );

    if (hasPermission) {
      await fetchAudioFiles();
      logger.i('Permission granted');
    } else {
      logger.e('Permission denied');
    }
  }

  Future<void> fetchAudioFiles() async {
    try {
      songs = await audioQuery.querySongs();
      setState(() {});
    } catch (e) {
      logger.e('Error fetching audio files: $e');
    }
  }

  Future<Uint8List?> getArtwork(int songId) async {
    try {
      final Uint8List? artwork =
          await audioQuery.queryArtwork(songId, ArtworkType.AUDIO, size: 200);
      return artwork;
    } catch (e) {
      print('Error fetching artwork: $e');
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: const LeftMenuDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music Player'),
      ),
      body: fileAccess
          ? const Center(
              child: Text('No music files found'),
            )
          : Stack(
              children: [
                ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return SongListView(
                      title: songs[index].title,
                      artist: songs[index].artist ?? 'Unknown',
                      onTap: () {
                        setState(() {
                          selectedSong = songs[index];
                        });
                       AudioPlayerModel().playLocalMusic(selectedSong?.data);
                      },
                      leadingIcon: FutureBuilder(
                        future: getArtwork(songs[index].id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
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
                      child: SelectedSongView(
                        artist: selectedSong?.artist ?? 'Unknown',
                        title: selectedSong?.title ?? 'Unknown',
                        onTap: () {
                          _scaffoldKey.currentState?.showBottomSheet(
                            (context) => PlayingSongScreen(
                              selectedSong: selectedSong,
                            ),
                            enableDrag: true,
                          );
                        },
                        trailingIcon: AudioPlayerModel().isPlaying
                            ? const Icon(Icons.pause_rounded)
                            : const Icon(Icons.play_arrow),
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
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}