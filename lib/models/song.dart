import 'package:harmonymusic/models/thumbnail.dart';

class Song {
  Song({
    required this.songId,
    required this.title,
    required this.thumbnail,
    required this.artist,
    this.album,
    this.length
    //required this.audioStreams,
  });

  String songId;
  String title;
  Thumbnail thumbnail;
  List<dynamic> artist;
  Map<String,dynamic>? album;
  String? length;
  //Map<String, AudioStream> audioStreams;
  //List<RelatedStream> relatedStreams;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
          songId: json["videoId"],
          title: json["title"],
          thumbnail: Thumbnail(json["thumbnails"][0]['url']) ,
          artist:json['artists'],
          album: json['album'],
          length: json['length']
          // audioStreams: {
          //   for (var element in json["audioStreams"])
          //     element["quality"]: AudioStream.fromJson(element)
          // }
          );

  Map<String, dynamic> toJson() => {
        "videoId": songId,
        "title": title,
        "thumbnails": [{'url':thumbnail.url}],
        "artists": artist,
        "album":album,
        "length":length
        // "audioStreams":
        //     List<dynamic>.from(audioStreams.values.map((x) => x.toJson())),
      };
}

