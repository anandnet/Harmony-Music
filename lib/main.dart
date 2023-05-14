import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/services/audio_handler.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/home.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/settings_screen_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'ui/screens/home_screen_controller.dart';
import 'ui/utils/home_library_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHive();
  _setAppInitPrefs();
  startApplicationServices();
  Get.put<AudioHandler>(await initAudioService(), permanent: true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == "AppLifecycleState.resumed") {
        // SystemChrome.setSystemUIOverlayStyle(
        //   SystemUiOverlayStyle(
        //       statusBarIconBrightness: Brightness.light,
        //       statusBarColor: Colors.transparent,
        //       systemNavigationBarColor: Colors.white.withOpacity(0.002),
        //       systemNavigationBarDividerColor: Colors.transparent,
        //       systemNavigationBarIconBrightness: Brightness.light,
        //       systemStatusBarContrastEnforced: false,
        //       systemNavigationBarContrastEnforced: true),
        // );
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
      return null;
    });
    return GetX<ThemeController>(builder: (controller) {
      return GetMaterialApp(
        title: 'Harmony Music',
        theme: controller.themedata.value,
        home: const Home(),
      );
    });
  }
}

Future<void> startApplicationServices() async {
  Get.lazyPut(() => MusicServices(true), fenix: true);
  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => PlayerController(), fenix: true);
  Get.lazyPut(() => HomeScreenController());
  Get.lazyPut(() => LibrarySongsController(), fenix: true);
  Get.lazyPut(() => LibraryPlaylistsController(), fenix: true);
  Get.lazyPut(() => LibraryAlbumsController(), fenix: true);
  Get.lazyPut(() => LibraryArtistsController(), fenix: true);
  Get.lazyPut(() => SettingsScreenController(), fenix: true);
  // final success = await AndroidPowerManager.requestIgnoreBatteryOptimizations();
  // (success != null && success)
  //     ? printINFO("Power manager Activated")
  //     : printERROR("Power manager Activation Failed");
}

initHive() async {
  Directory applicationDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(applicationDirectory.path);
  await Hive.openBox("SongsCache");
  await Hive.openBox('SongsUrlCache');
  await Hive.openBox("AppPrefs");
}

void _setAppInitPrefs() {
  final appPrefs = Hive.box("AppPrefs");
  if (appPrefs.isEmpty) {
    appPrefs.putAll({
      'themeModeType': 0,
      "cacheSongs": false,
      "skipSilenceEnabled": false,
      'streamingQuality': 1,
      'themePrimaryColor': 4278199603
    });
  }
}
