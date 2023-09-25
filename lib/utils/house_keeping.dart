import 'dart:io';

import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../services/utils.dart';

void startHouseKeeping() {
  removeExpiredSongsUrlFromDb();
}

Future<void> removeExpiredSongsUrlFromDb() async {
  try {
    final songsUrlCacheBox = Hive.box("SongsUrlCache");
    final songsUrlCacheKeysList =
        songsUrlCacheBox.keys.whereType<String>().toList();
    for (var i = 0; i < songsUrlCacheKeysList.length; i++) {
      final songUrlKey = songsUrlCacheKeysList[i];
      final songUrl = songsUrlCacheBox.get(songUrlKey);
      if (songUrl == null ||
          (songUrl != null && isExpired(url: songUrl[0] as String))) {
        await songsUrlCacheBox.delete(songUrlKey);
      }
    }
  // ignore: empty_catches
  } catch (e) {}
}

void removeCachedFileCreatedUsingProxy() async {
  final cacheDir = (await getTemporaryDirectory()).path;
  final proxyCachedSongs = await Hive.openBox("proxyCachedSongs");
  final allSongIdList = proxyCachedSongs.values.toList();
  for(int i = 0;i< allSongIdList.length;i++){
    printINFO(allSongIdList[i]);
    if(await File("$cacheDir/cachedSongs/${allSongIdList[i]}.mp3").exists()){
      await File("$cacheDir/cachedSongs/${allSongIdList[i]}.mp3").delete();
    }
  }
  await proxyCachedSongs.clear();
  proxyCachedSongs.close();
  printINFO("All proxy cached File removed");
}
