import 'dart:core';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

//Not in use for now
// Future<List<String>?> getSongUrlFromPiped(String songId,
//     {String defaultUrl = "https://pipedapi.kavin.rocks"}) async {
//   try {
//     if (songId.substring(0, 4) == "MPED") {
//       songId = songId.substring(4);
//     }
//     final response = await Dio().get("$defaultUrl/streams/$songId");
//     if (response.statusCode == 200) {
//       final audioStream = response.data["audioStreams"] as List;
//       final x =
//           audioStream.firstWhere((item) => (item['itag'].toString() == "251"));

//       final y =
//           audioStream.firstWhere((item) => (item['itag'].toString() == "251"));

//       return [y['url'], x['url']];
//     } else {
//       return null;
//     }
//   } catch (e) {
//     return null;
//   }
// }

Future<List<String>?> getSongUrlFromExplode(
  String songId,
) async {
  try {
    if (songId.substring(0, 4) == "MPED") {
      songId = songId.substring(4);
    }
    final songStreamManifest =
        await (YoutubeExplode().videos.streamsClient.getManifest(songId));
    songStreamManifest.video.first;
    final streamUriList = songStreamManifest.audioOnly.sortByBitrate();
    return [
      streamUriList.last.url.toString(),
      streamUriList
          .firstWhere((element) => (element.tag == 251) || element.tag == 140)
          .url
          .toString()
    ];
  } catch (e) {
    return null;
  }
}

