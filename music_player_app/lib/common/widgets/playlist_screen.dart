import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_new_play_list_drawer.dart';
import '../models/shared_data_model.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({Key? key});

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  int count = 0;
  List<String> playlists = [];
  LocalSavingDataModel localDataModel = LocalSavingDataModel();

  @override
  void initState() {
    super.initState();
    fetchPlaylists(); // Fetch playlists when the screen initializes
  }

  // Method to fetch playlists
  Future<void> fetchPlaylists() async {
    final fetchedPlaylists = await localDataModel.getPlayLists();
    setState(() {
      playlists = fetchedPlaylists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Playlist($count)', style: Theme.of(context).textTheme.titleLarge),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CreatePlayListDrawer();
                        },
                      ).then((_) async {
                        await fetchPlaylists();

                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      setState(() {
                        // count--;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(playlists[index]),
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
