import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'common/models/audio_model.dart';
import 'common/models/music_settings_model.dart';
import 'common/models/shared_data_model.dart';
import 'widgets/home_page.dart';

void main() async {
  final logger = Logger();
  List<SongModel> songList = [];
  WidgetsFlutterBinding.ensureInitialized();
  var storageAccess = await Permission.audio.status.isGranted ||
      await Permission.storage.status.isGranted;
  logger.i('Storage access: $storageAccess');

  if (storageAccess) {
    songList = await MusicSettings.instance.fetchAudioFiles();
    MusicSettings.instance.setSelectedSong =
        await LocalSavingDataModel().getCurrentPlayingSong();
  }

  runApp(MyApp(
    storageAccess: storageAccess,
    songList: songList,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.storageAccess,
    required this.songList,
    super.key,
  });

  final bool storageAccess;
  final List<SongModel> songList;

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        body: ChangeNotifierProvider(
          create: (context) => AudioPlayerModel(),
          child: HomePage(
            storageAccess: storageAccess,
            songList: songList,
          ),
        ),
      ),
    );
  }
}
