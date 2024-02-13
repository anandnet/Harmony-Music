// ignore_for_file: file_names

import 'package:audio_service/audio_service.dart';
import '../models/thumbnail.dart';

class MediaItemBuilder {
  static MediaItem fromJson(dynamic json, {String? url}) {
    String artistName = '';
    if (json['artists'] != null) {
      for (dynamic artist in json['artists']) {
        artistName += "${artist['name']} • ";
      }
    }

    Map? album;
    if (json['album'] != null) {
      if (json['album']['id'] != null) {
        album = json['album'];
      }
    }

    return MediaItem(
        id: json["videoId"],
        title: json["title"],
        duration: json['duration'] != null
            ? Duration(seconds: json['duration'])
            : toDuration(json['length']),
        album: album != null ? album['name'] : null,
        artist: artistName == ""
            ? artistName
            : artistName.substring(0, artistName.length - 2),
        artUri: Uri.parse(Thumbnail(json["thumbnails"][0]['url']).high),
        extras: {
          'url': json['url'] ?? url,
          'length': json['length'],
          'album': album,
          'artists': json['artists'],
          'date': json['date']
        });
  }

  static Duration? toDuration(String? time) {
    if (time == null) {
      return null;
    }

    int sec = 0;
    final splitted = time.split(":");
    if (splitted.length == 3) {
      sec += int.parse(splitted[0]) * 3600 +
          int.parse(splitted[1]) * 60 +
          int.parse(splitted[2]);
    } else if (splitted.length == 2) {
      sec += int.parse(splitted[0]) * 60 + int.parse(splitted[1]);
    } else if (splitted.length == 1) {
      sec += int.parse(splitted[0]);
    }
    return Duration(seconds: sec);
  }

  static Map<String, dynamic> toJson(MediaItem mediaItem) => {
        "videoId": mediaItem.id,
        "title": mediaItem.title,
        'album': mediaItem.extras!['album'],
        'artists': mediaItem.extras!['artists'],
        'length': mediaItem.extras!['length'],
        'duration': mediaItem.duration?.inSeconds,
        'date': mediaItem.extras!['date'],
        'thumbnails': [
          {'url': mediaItem.artUri.toString()}
        ],
        'url': mediaItem.extras!['url']
      };
}
