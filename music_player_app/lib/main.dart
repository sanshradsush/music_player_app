import 'package:device_info_plus/device_info_plus.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({
    required this.storageAccess,
    required this.songList,
    super.key,
  });

  final bool storageAccess;
  final List<SongModel> songList;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Logger logger = Logger();
  List<SongModel> songs = [];
  bool storageAccess = false;

  @override
  void initState() {
    super.initState();
    songs = widget.songList;
    storageAccess = widget.storageAccess;
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
      songs = await MusicSettings.instance.fetchAudioFiles();
      storageAccess = true;
      setState(() {});
    } else {
      logger.e('Storage permission not granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return storageAccess
        ? MaterialApp(
            home: Scaffold(
                key: scaffoldKey,
                body: ChangeNotifierProvider(
                  create: (context) => AudioPlayerModel(),
                  child: HomePage(
                    songList: songs,
                  ),
                )),
          )
        : MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: const Text('Music Player'),
              ),
              key: scaffoldKey,
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    await requestPermissions();
                  },
                  child: const Text('Allow'),
                ),
              ),
            ),
          );
  }
}
