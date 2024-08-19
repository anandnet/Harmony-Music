import '../models/thumbnail.dart';

class AlbumContent {
  AlbumContent({required this.title, required this.albumList});
  final String title;
  final List<Album> albumList;

  factory AlbumContent.fromJson(Map<dynamic, dynamic> json) => AlbumContent(
      title: json['title'],
      albumList:
          (json['albumlist'] as List).map((e) => Album.fromJson(e)).toList());
  Map<String, dynamic> toJson() => {
        "type": "Album Content",
        "title": title,
        'albumlist': albumList.map((e) => e.toJson()).toList()
      };
}

class Album {
  Album(
      {required this.title,
      required this.browseId,
      required this.artists,
      this.year,
      this.description,
      this.audioPlaylistId,
      required this.thumbnailUrl});
  final String browseId;
  final String? audioPlaylistId;
  final String title;
  final String? description;
  final List<Map<dynamic, dynamic>>? artists;
  final String? year;
  final String thumbnailUrl;

  factory Album.fromJson(Map<dynamic, dynamic> json) => Album(
      title: json["title"],
      browseId: json["browseId"],
      artists: json["artists"] != null
          ? List<Map<dynamic, dynamic>>.from(json["artists"])
          : [
              {'name': ''}
            ],
      year: json['year'],
      audioPlaylistId: json['audioPlaylistId'],
      description: json['description'] ?? json["type"] ?? "Album",
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).medium);

  Map<String, dynamic> toJson() => {
        "title": title,
        "browseId": browseId,
        'artists': artists,
        'year': year,
        'audioPlaylistId': audioPlaylistId,
        'description': description,
        'thumbnails': [
          {'url': thumbnailUrl}
        ]
      };
}
