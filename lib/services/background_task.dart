import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:harmonymusic/services/music_service.dart';

import '../models/media_Item_builder.dart';


Future<void> getUpNextSong(List args) async {
  SendPort sendPort = args[0] as SendPort;
  final res =
      await (args[1] as MusicServices).getWatchPlaylist(videoId: args[2]);
  List<MediaItem> upNextSongList = (res['tracks'])
      .map<MediaItem>((item) => MediaItemBuilder.fromJson(item))
      .toList();
  sendPort.send(upNextSongList);
  //return upNextSongList;
}
