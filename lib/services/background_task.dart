import 'package:harmonymusic/services/music_service.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/song.dart';

Future<void> cacheQueueitemsUrl(List<dynamic> args) async {
  print("==>>>>> Isolate started ${args[2]}");
  Hive.init(args[0] as String);
  Hive.registerAdapter(SongAdapter());
  await Hive.openBox("SongsCache");
  await Hive.openBox('SongsUrlCache');
  final songsCacheBox = Hive.box("SongsCache");
  final songsUrlCacheBox = Hive.box('SongsUrlCache');
  final musicServices = MusicServices();
  for (Song item in args[1] as List<Song>) {
    await checkNGetUrl(
        item.songId, musicServices, songsCacheBox, songsUrlCacheBox);
  }
  print("url Cached");
}

Future<void> checkNGetUrl(String songId, musicServices, songsCacheBox, songsUrlCacheBox) async {
  print('Running......');
  if (songsCacheBox.containsKey(songId)) {
    return ;
  } else {
    //check if song stream url is cached and allocate url accordingly
    if (songsUrlCacheBox.containsKey(songId)) {
      if (_isUrlExpired(songsUrlCacheBox.get(songId))) {
        final url = (await musicServices.getSongUri(songId)).toString();
        songsUrlCacheBox.put(songId, url);
      }
    } else {
      final url = (await musicServices.getSongUri(songId)).toString();
      songsUrlCacheBox.put(songId, url);
    }
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
