import 'package:harmonymusic/models/thumbnail.dart';

class AlbumContent{
  AlbumContent({required this.title,required this.albumList});
  final String title;
  final List<Album> albumList;
  factory AlbumContent.fromJson(Map<dynamic,dynamic> json)=>AlbumContent(title: json["title"], albumList:(json["contents"]).map<Album>((item)=>Album.fromJson(item)).toList());
}

class Album{
  Album(
      {required this.title,
      required this.browseId,
      required this.artist,
      required this.thumbnail});
  final String browseId;
  final String title;
  final String artist;
  final Thumbnail thumbnail;

  factory Album.fromJson(Map<dynamic,dynamic> json)=>Album(title: json["title"], browseId: json["browseId"], artist: json["artist"], thumbnail: Thumbnail(json["thumbnails"][0]["url"]));
}