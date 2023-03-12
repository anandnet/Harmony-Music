import 'package:harmonymusic/models/thumbnail.dart';
import 'package:hive_flutter/adapters.dart';

part 'song.g.dart';

@HiveType(typeId: 0)
class Song {
  Song(
      {required this.songId,
      required this.title,
      required this.thumbnailUrl,
      required this.artist,
      this.album,
      this.length,
      this.url
      //required this.audioStreams,
      });
  @HiveField(0)
  String songId;

  @HiveField(1)
  String title;

  @HiveField(2)
  String thumbnailUrl;

  @HiveField(3)
  List<dynamic> artist;

  @HiveField(4)
  String? url;

  @HiveField(5)
  Map<String, dynamic>? album;

  @HiveField(6)
  String? length;

  //Map<String, AudioStream> audioStreams;
  //List<RelatedStream> relatedStreams;

  factory Song.fromJson(Map<String, dynamic> json, {String? url}) => Song(
        songId: json["videoId"],
        title: json["title"],
        thumbnailUrl: Thumbnail(json["thumbnails"][0]['url']).medium,
        artist: json['artists'],
        album: json['album'],
        length: json['length'],
        url: url,
        // audioStreams: {
        //   for (var element in json["audioStreams"])
        //     element["quality"]: AudioStream.fromJson(element)
        // }
      );

  Map<String, dynamic> toJson() => {
        "videoId": songId,
        "url": url,
        "title": title,
        "thumbnails": [
          {'url': thumbnailUrl}
        ],
        "artists": artist,
        "album": album,
        "length": length
        // "audioStreams":
        //     List<dynamic>.from(audioStreams.values.map((x) => x.toJson())),
      };

  set setUrl(String url) {
    url = url;
  }
}
