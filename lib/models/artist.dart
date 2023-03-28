import 'package:harmonymusic/models/thumbnail.dart';

class Artist{
  Artist({required this.name,required this.browseId,required this.radioId,required this.thumbnailUrl});
  final String name; 
  final String browseId;
  final String radioId;
  final String thumbnailUrl;
  factory Artist.fromJson(dynamic json)=>Artist(
    name: json['artist'],
    browseId: json['browseId'],
    radioId: json['radioId'],
    thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).high
  );
}