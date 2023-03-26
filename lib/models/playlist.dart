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
      required this.thumbnailUrl});
  final String playlistId;
  final String title;
  final String? description;
  final String thumbnailUrl;

  factory Playlist.fromJson(Map<dynamic, dynamic> json) => Playlist(
      title: json["title"],
      playlistId: json["playlistId"],
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).high,
      description: json["description"]);
}
