import 'package:harmonymusic/models/thumbnail.dart';

class Song {
  Song({
    required this.songId,
    required this.title,
    required this.thumbnail,
    required this.artist,
    required this.album,
    this.length
    //required this.audioStreams,
  });

  String songId;
  String title;
  Thumbnail thumbnail;
  List<dynamic> artist;
  Map<String,dynamic> album;
  String? length;
  //Map<String, AudioStream> audioStreams;
  //List<RelatedStream> relatedStreams;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
          songId: json["videoId"],
          title: json["title"],
          thumbnail: Thumbnail(json["thumbnails"][1]['url']) ,
          artist:json['artists'],
          album: json['album'],
          length: json['length']
          // audioStreams: {
          //   for (var element in json["audioStreams"])
          //     element["quality"]: AudioStream.fromJson(element)
          // }
          );

  Map<String, dynamic> toJson() => {
        "songID": songId,
        "title": title,
        "thumbnailUrl": thumbnail,
        "artist": artist,
        "album":album
        // "audioStreams":
        //     List<dynamic>.from(audioStreams.values.map((x) => x.toJson())),
      };
}

