import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'common/models/audio_model.dart';
import 'widgets/home_page.dart';

void main() async {
  final logger = Logger();
  WidgetsFlutterBinding.ensureInitialized();
  var storageAccess = await Permission.audio.status.isGranted ||
      await Permission.storage.status.isGranted;
  logger.i('Storage access: $storageAccess');

  runApp(MyApp(
    storageAccess: storageAccess,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.storageAccess,
    super.key,
  });
  final bool storageAccess;

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
          ),
        ),
      ),
    );
  }
}
