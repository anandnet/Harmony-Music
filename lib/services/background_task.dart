import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import '../models/song.dart';

Future<void> cacheQueueitemsUrl(List<dynamic> args) async {
  Hive.init(args[0] as String);
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox("SongsCache");
  await Hive.openBox('SongsUrlCache');
  for (MediaItem item in args[1] as List<MediaItem>) {
   await checkNGetUrl(item.id);
  }
  print("url Cached");
}

Future<String?> checkNGetUrl(String songId) async {
  final songsCacheBox = Hive.box("SongsCache");
  final songsUrlCacheBox =Hive.box('SongsUrlCache');
  final musicServices = MusicServices();
  if (songsCacheBox.containsKey(songId)) {
    return (songsCacheBox.get(songId) as Song).url;
  } else {
    //check if song stream url is cached and allocate url accordingly
    String url = "";
    if (songsUrlCacheBox.containsKey(songId)) {
      if (_isUrlExpired(songsUrlCacheBox.get(songId))) {
        url = (await musicServices.getSongUri(songId)).toString();
        songsUrlCacheBox.put(songId, url);
      } else {
        url = songsUrlCacheBox.get(songId);
      }
    } else {
      url = (await musicServices.getSongUri(songId)).toString();
      songsUrlCacheBox.put(songId, url);
    }
    return url;
  }
}

///Check if Steam Url is expired
bool _isUrlExpired(String url) {
  RegExpMatch? match = RegExp(".expire=([0-9]+)?&").firstMatch(url);
  if (match != null) {
    if (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1800 <
        int.parse(match[1]!)) {
      print("Not Expired");
      return false;
    }
  }
  print("Expired");
  return true;
}
