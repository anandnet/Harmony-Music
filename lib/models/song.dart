class Song {
  Song({
    required this.songId,
    required this.title,
    required this.thumbnail,
    required this.artist,
    required this.album,
    //required this.audioStreams,
  });

  String songId;
  String title;
  Thumbnail thumbnail;
  List<Map<String,dynamic>> artist;
  Map<String,dynamic> album;
  //Map<String, AudioStream> audioStreams;
  //List<RelatedStream> relatedStreams;

  factory Song.fromJson(Map<String, dynamic> json) => Song(
          songId: json["videoId"],
          title: json["title"],
          thumbnail: Thumbnail(json["thumbnails"][1]['url']) ,
          artist:json['artists'],
          album: json['album'],
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

class Thumbnail{
  Thumbnail(this._url);
  final String _url;
  String sizewith(int size)=> "${_url.split("=")[0]}=w$size-h$size-l90-rj";
}
