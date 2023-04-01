import 'package:harmonymusic/models/thumbnail.dart';

class Artist {
  Artist({
    required this.name,
    required this.browseId,
    this.radioId,
    required this.thumbnailUrl,
    this.subscribers,
  });
  final String name;
  final String browseId;
  final String? radioId;
  final String? subscribers;
  final String thumbnailUrl;
  factory Artist.fromJson(dynamic json) => Artist(
      name: json['artist'],
      browseId: json['browseId'],
      radioId: json['radioId'],
      subscribers: (json['subscribers']).runtimeType.toString()=="String"?json['subscribers']: json['subscribers']['text'],
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).high);
}
