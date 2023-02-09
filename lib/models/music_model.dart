import 'dart:convert';

Song songDetailsFromJson(String str,String songId) =>
    Song.fromJson(json.decode(str),songId);

String musicModelToJson(Song data) => json.encode(data.toJson());

class Song{
  Song({
    required this.songId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.audioStreams,
  });

  String songId;
  String title;
  String thumbnailUrl;
  int duration;
  List<AudioStream> audioStreams;
  //List<RelatedStream> relatedStreams;

  factory Song.fromJson(Map<String, dynamic> json,String songId) => Song(
        songId: songId,
        title: json["title"],
        thumbnailUrl: json["thumbnailUrl"],
        duration: json["duration"],
        audioStreams: List<AudioStream>.from(
            json["audioStreams"].map((x) => AudioStream.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "songID":songId,
        "title": title,
        "thumbnailUrl": thumbnailUrl,
        "duration": duration,
        "audioStreams": List<dynamic>.from(audioStreams.map((x) => x.toJson())),
      };
}

class AudioStream {
  AudioStream({
    required this.url,
    required this.format,
    required this.quality,
    required this.mimeType,
    required this.codec,
    this.audioTrackId,
    this.audioTrackName,
    required this.videoOnly,
    required this.bitrate,
    required this.initStart,
    required this.initEnd,
    required this.indexStart,
    required this.indexEnd,
    required this.width,
    required this.height,
    required this.fps,
  });

  String url;
  String format;
  String quality;
  String mimeType;
  String codec;
  dynamic audioTrackId;
  dynamic audioTrackName;
  bool videoOnly;
  int bitrate;
  int initStart;
  int initEnd;
  int indexStart;
  int indexEnd;
  int width;
  int height;
  int fps;

  factory AudioStream.fromJson(Map<String, dynamic> json) => AudioStream(
        url: json["url"],
        format: json["format"],
        quality: json["quality"],
        mimeType: json["mimeType"],
        codec: json["codec"],
        audioTrackId: json["audioTrackId"],
        audioTrackName: json["audioTrackName"],
        videoOnly: json["videoOnly"],
        bitrate: json["bitrate"],
        initStart: json["initStart"],
        initEnd: json["initEnd"],
        indexStart: json["indexStart"],
        indexEnd: json["indexEnd"],
        width: json["width"],
        height: json["height"],
        fps: json["fps"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "format": format,
        "quality": quality,
        "mimeType": mimeType,
        "codec": codec,
        "audioTrackId": audioTrackId,
        "audioTrackName": audioTrackName,
        "videoOnly": videoOnly,
        "bitrate": bitrate,
        "initStart": initStart,
        "initEnd": initEnd,
        "indexStart": indexStart,
        "indexEnd": indexEnd,
        "width": width,
        "height": height,
        "fps": fps,
      };
}

class SongDetailsResponse{
  SongDetailsResponse({required this.song,required this.jsonResponse});
  final Song song;
  final dynamic jsonResponse;
}

