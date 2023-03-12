import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongUriService {
  final YoutubeExplode _yt = YoutubeExplode();

  Future<Uri?> getSongUri(String songId,
      {AudioQuality quality = AudioQuality.Low}) async {
    try {
      final songStreamManifest =
          await _yt.videos.streamsClient.getManifest(songId);
      final streamUriList = songStreamManifest.audioOnly.sortByBitrate();
      if (quality == AudioQuality.High) {
        return songStreamManifest.audioOnly.withHighestBitrate().url;
      } else if (quality == AudioQuality.Medium) {
        return streamUriList[streamUriList.length ~/ 2].url;
      } else {
        return streamUriList[0].url;
      }
    } catch (e) {
      return null;
    }
  }
}

enum AudioQuality { High, Medium, Low }

// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:just_audio/just_audio.dart';
// import '../models/song.dart';

// class SongUriService {
//   Future<Uri> getSongUri(String songId) async {
//     final response =
//         await Dio().get("https://watchapi.whatever.social/streams/$songId");
//     if (response.statusCode == 200) {
//       final responseUrl = ((response.data["audioStreams"])
//           .firstWhere((val) => val["quality"] == "48 kbps"))["url"];
//           print("hello");
//       return Uri.parse(responseUrl);
//     } else {
//       return getSongUri(songId);
//     }
//   }
// }
