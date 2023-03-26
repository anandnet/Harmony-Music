import 'package:audio_service/audio_service.dart';
import 'package:harmonymusic/models/thumbnail.dart';

class MediaItemBuilder {
  static MediaItem fromJson(dynamic json, {String? url}) {
    String artistName = '';
    for (dynamic artist in json['artists']) {
      artistName += "${artist['name']} • ";
    }
    return MediaItem(
        id: json["videoId"],
        title: json["title"],
        album: json['album']!=null ? json['album']['name']:null ,
        artist: artistName.substring(0,artistName.length-2),
        artUri: Uri.parse(Thumbnail(json["thumbnails"][0]['url']).high),
        extras: {
          'url': json['url'] ?? url,
          'length': json['length'],
          'album': json['album'],
          'artists': json['artists']
        });
  }

  static Map<String, dynamic> toJson(MediaItem mediaItem) => {
        "videoId": mediaItem.id,
        "title": mediaItem.title,
        'album': mediaItem.extras!['album'],
        'artists': mediaItem.extras!['artists'],
        'length': mediaItem.extras!['length'],
        'thumbnails': [
          {'url': mediaItem.artUri.toString()}
        ],
        'url': mediaItem.extras!['url']
      };
}
