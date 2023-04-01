import 'package:harmonymusic/models/thumbnail.dart';

class AlbumContent {
  AlbumContent({required this.title, required this.albumList});
  final String title;
  final List<Album> albumList;
  factory AlbumContent.fromJson(Map<dynamic, dynamic> json) => AlbumContent(
      title: json["title"],
      albumList: (json["contents"])
          .map<Album?>((item) {
            if (item.containsKey('browseId') && !item.containsKey('videoId')) {
              return Album.fromJson(item);
            }
          })
          .whereType<Album>()
          .toList());
}

class Album {
  Album(
      {required this.title,
      required this.browseId,
      required this.artists,
      this.year,
      
      required this.thumbnailUrl});
  final String browseId;
  final String title;
  final List<Map<String, dynamic>>? artists;
  final String? year;
  final String thumbnailUrl;
  

  factory Album.fromJson(Map<dynamic, dynamic> json) => Album(
      title: json["title"],
      browseId: json["browseId"],
      artists:json["artists"]!=null? List<Map<String, dynamic>>.from(json["artists"]):[{'name':''}],
      year: json['year'],
      
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).high);
}
