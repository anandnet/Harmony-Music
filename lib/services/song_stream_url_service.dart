import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class SongStreamUrlService{
  SongStreamUrlService({required this.song});
  final Song song;

  Future<AudioSource?> get songStreamUrl {
    final response = Dio().get("https://watchapi.whatever.social/streams/${song.songId}").then((value) {
      if(value.statusCode==200){
        final responseUrl = ((value.data["audioStreams"]).firstWhere((val) => val["quality"] == "48 kbps"))["url"];
        return AudioSource.uri(Uri.parse(responseUrl),tag: song);
      }
    });

    return response;
  }
}
