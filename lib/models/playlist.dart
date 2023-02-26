import 'package:harmonymusic/models/thumbnail.dart';

class PlaylistContent {
  PlaylistContent({required this.title, required this.playlistList});
  final String title;
  final List<Playlist> playlistList;
  factory PlaylistContent.fromJson(Map<dynamic, dynamic> json) =>
      PlaylistContent(
          title: json["title"],
          playlistList: (json["contents"]).map<Playlist?>((item) {
            if (item.containsKey('playlistId') && !item.containsKey('videoId')) {
              return Playlist.fromJson(item);
            }
          }).whereType<Playlist>().toList());
}

class Playlist {
  Playlist(
      {required this.title,
      required this.playlistId,
      this.description,
      required this.thumbnail});
  final String playlistId;
  final String title;
  final String? description;
  final Thumbnail thumbnail;

  factory Playlist.fromJson(Map<dynamic, dynamic> json) => Playlist(
      title: json["title"],
      playlistId: json["playlistId"],
      thumbnail: Thumbnail(json["thumbnails"][0]["url"]),
      description: json["description"]);
}
