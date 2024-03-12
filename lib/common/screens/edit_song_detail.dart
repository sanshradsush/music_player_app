import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'scaffold.dart';

class EditSongDetailsScreen extends StatefulWidget {
  const EditSongDetailsScreen({
    required this.songModel,
    required this.onSaved,
    super.key,
  });

  final SongModel songModel;
  final VoidCallback onSaved;

  @override
  State<EditSongDetailsScreen> createState() => _EditSongDetailsScreenState();
}

class _EditSongDetailsScreenState extends State<EditSongDetailsScreen> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  Logger logger = Logger();
  String? titleText;
  String? artistText;
  String? albumText;
  String? genreText;
  TextEditingController? _titleController;
  TextEditingController? _artistController;
  TextEditingController? _albumController;
  TextEditingController? _genreController;
  Future<Uint8List?>? _artworkFuture;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: titleText = widget.songModel.title);
    _artistController =
        TextEditingController(text: artistText = widget.songModel.artist);
    _albumController =
        TextEditingController(text: albumText = widget.songModel.album);
    _genreController =
        TextEditingController(text: genreText = widget.songModel.genre);
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      'Edit Tags',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    //Todo: Handle saving Part
                    widget.onSaved();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      shape: BoxShape.rectangle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: FutureBuilder(
                      future: _artworkFuture ?? getArtwork(widget.songModel.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null) {
                          return Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
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
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artist',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _albumController,
                    decoration: const InputDecoration(
                      labelText: 'Album',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(
                      labelText: 'Genre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
