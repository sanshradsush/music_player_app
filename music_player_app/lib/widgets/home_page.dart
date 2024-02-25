import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../common/widgets/song_list_view.dart';

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

  @override
  void initState() {
    super.initState();
  }

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

  void checkAndRequestPermissions({bool retry = false}) async {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Music Player'),
      ),
      body: fileAccess
          ? const Center(
              child: Text('No music files found'),
            )
          : ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return SongListView(
                  title: songs[index].title,
                  artist: songs[index].artist ?? 'Unknown',
                  onTap: () {},
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
                        return const CircleAvatar(
                          backgroundColor: Colors.grey,
                        );
                      }
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: Colors.grey,
              ),
              itemCount: songs.length,
            ),
    );
  }
}
