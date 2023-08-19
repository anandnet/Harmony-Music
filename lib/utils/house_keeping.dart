import 'package:hive/hive.dart';

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
