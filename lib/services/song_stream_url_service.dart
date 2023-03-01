import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongUriService{
  final YoutubeExplode _yt =YoutubeExplode();
  
  Future<Uri> getSongUri(String songId,{AudioQuality quality = AudioQuality.Low}) async {
    final songStreamManifest =await _yt.videos.streamsClient.getManifest(songId);
    final streamUriList = songStreamManifest.audioOnly.sortByBitrate();
    if(quality==AudioQuality.High){
      return songStreamManifest.audioOnly.withHighestBitrate().url;
    }else if(quality == AudioQuality.Medium){
      return streamUriList[streamUriList.length~/2].url;
    }else{
      return streamUriList[0].url;
    }
  }
}

enum AudioQuality{
  High,
  Medium,
  Low
}





// import 'dart:developer';

// import 'package:dio/dio.dart';
// import 'package:just_audio/just_audio.dart';
// import '../models/song.dart';

// class SongStreamUrlService{
//   SongStreamUrlService({required this.song});
//   final Song song;

//   Future<AudioSource?> get songStreamUrl {
//     final response = Dio().get("https://watchapi.whatever.social/streams/${song.songId}").then((value) {
//       if(value.statusCode==200){
//         final responseUrl = ((value.data["audioStreams"]).firstWhere((val) => val["quality"] == "48 kbps"))["url"];
//         return AudioSource.uri(Uri.parse(responseUrl),tag: song);
//       }
//     });

//     return response;
//   }
// }
