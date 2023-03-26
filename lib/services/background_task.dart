import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/utils.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> cacheQueueitemsUrl(List<dynamic> args) async {
  SendPort sendPort = args[0] as SendPort;
  Hive.init(args[1] as String);
  final songsCacheBox = await Hive.openBox(
    "SongsCache",
  );
  final songsUrlCacheBox = await Hive.openBox('SongsUrlCache');
  final musicServices = MusicServices(false);
  for (MediaItem item in args[2] as List<MediaItem>) {
    await checkNGetUrl(
        item.id, songsCacheBox, songsUrlCacheBox, musicServices);
  }
  printINFO("All url Cached");
  await Hive.close();
  sendPort.send("Isolate ended");
  Isolate.exit();
}

Future<void> checkNGetUrl(String songId, dynamic songsCacheBox,
    dynamic songsUrlCacheBox, MusicServices musicServices) async {
  if (songsCacheBox.containsKey(songId)) {
    printINFO("Song alredy cached $songId", tag: "Isolate");
    return;
  } else {
    //check if song stream url is cached and allocate url accordingly
    if (songsUrlCacheBox.containsKey(songId)) {
      if (isExpired(url: songsUrlCacheBox.get(songId))) {
        final url = (await musicServices.getSongUri(songId)).toString();
        songsUrlCacheBox.put(songId, url);
      }
      return;
    } else {
      final url = (await musicServices.getSongUri(songId)).toString();
      songsUrlCacheBox.put(songId, url);
      printINFO("Song Url cached $songId", tag: "Isolate");
    }
  }
}
