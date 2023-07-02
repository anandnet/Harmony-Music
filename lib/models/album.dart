import 'package:harmonymusic/models/thumbnail.dart';

class AlbumContent {
  AlbumContent({required this.title, required this.albumList});
  final String title;
  final List<Album> albumList;
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
  final List<Map<dynamic, dynamic>>? artists;
  final String? year;
  final String thumbnailUrl;
  

  factory Album.fromJson(Map<dynamic, dynamic> json) => Album(
      title: json["title"],
      browseId: json["browseId"],
      artists:json["artists"]!=null? List<Map<dynamic, dynamic>>.from(json["artists"]):[{'name':''}],
      year: json['year'],
      
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).medium);

   Map<String,dynamic> toJson()=>{
    "title":title,
    "browseId":browseId,
    'artists':artists,
    'year':year,
    'thumbnails':[{'url':thumbnailUrl}]
   };
}
