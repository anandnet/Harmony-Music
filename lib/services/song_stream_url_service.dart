import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/song.dart';

class SongStreamUrlService{
  SongStreamUrlService({required this.song});
  final Song song;

  Future<Map> get songStreamUrl async {
  final response = await Dio().get("https://pipedapi.kavin.rocks/streams/${song.songId}");

  if (response.statusCode == 200) {
    final x = Map<String,String>.fromIterable(response.data["audioStreams"],key:(item)=>item["quality"],value: (item)=>item["url"]);
    //inspect(x);
    return x;
  } else {
    print("error loading video id ${song.songId} & RESPONSE CODE ${response.statusCode}");
    return songStreamUrl;
  }
  }
}
