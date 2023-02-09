import 'dart:convert';
import 'package:harmonymusic/models/music_model.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../ui/player/utils.dart';

List<String> realtedSongsList = [];

Future<dynamic> getSongdata(String songId, bool first) async {
  final response =
      await http.get(Uri.parse("https://pipedapi.kavin.rocks/streams/$songId"));

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final Song song = Song.fromJson(jsonResponse, songId);
    if (first) {
      return SongDetailsResponse(song: song, jsonResponse: jsonResponse);
    } else {
      return song;
    }
  } else {
    print("error loading video id${songId}");
  }
}

Future<List> getRelatedSongsList(dynamic jsonResponse) async {
  // final relatedSongIdList = await jsonResponse["relatedStreams"].map((val) async {
  //   if (val["type"] == "stream") {
  //   return await getSongdata((val["url"]).split("=")[1], false);
  //   }
  // }).toList();

  // final relatedSongIdList =
  //     Stream.fromIterable(jsonResponse["relatedStreams"]).asyncMap((val) {
  //   if (val["type"] == "stream") {
  //     print((val["url"]).split("=")[1]);
  //     return getSongdata((val["url"]).split("=")[1], false);
  //   }
  // }).toList();

  final list = [];
  for (final val in (jsonResponse["relatedStreams"])) {
    if (val["type"] == "stream") {
      list.add(await getSongdata(((val["url"]).split("="))[1], false));
    }
  }
  print(list);
  return list;
}
