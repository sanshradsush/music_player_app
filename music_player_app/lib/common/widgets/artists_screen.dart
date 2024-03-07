import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/music_settings_model.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({
    super.key,
  });

  @override
  State<ArtistsScreen> createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen> {
  MusicSettings musicSettings = MusicSettings.instance;
  List<ArtistModel> artists = [];

  @override
  void initState() {
    super.initState();
    fetchArtistlists();
  }

  Future<void> fetchArtistlists() async {
    final fetchedPlaylists = await musicSettings.fetchArtists();
    setState(() {
      artists = fetchedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Artist(${artists.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: artists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(artists[index].artist),
                  subtitle: Text(
                      '${artists[index].numberOfAlbums} albums | ${artists[index].numberOfTracks} songs'),
                  // Add functionality for each playlist item if needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
