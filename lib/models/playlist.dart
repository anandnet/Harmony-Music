import 'package:audio_service/audio_service.dart' show MediaItem;

import '../models/thumbnail.dart';

class PlaylistContent {
  PlaylistContent({required this.title, required this.playlistList});
  final String title;
  final List<Playlist> playlistList;

  factory PlaylistContent.fromJson(Map<dynamic, dynamic> json) =>
      PlaylistContent(
          title: json['title'],
          playlistList: (json['playlists'] as List)
              .map((e) => Playlist.fromJson(e))
              .toList());
  Map<String, dynamic> toJson() => {
        "type": "Playlist Content",
        "title": title,
        "playlists": playlistList.map((e) => e.toJson()).toList()
      };
}

class Playlist {
  Playlist(
      {required this.title,
      required this.playlistId,
      this.description,
      required this.thumbnailUrl,
      this.songCount,
      this.isPipedPlaylist = false,
      this.isCloudPlaylist = true});
  final String playlistId;
  String title;
  final bool isPipedPlaylist;
  final String? description;
  String thumbnailUrl;
  final String? songCount;
  final bool isCloudPlaylist;
  static const thumbPlaceholderUrl =
      "https://raw.githubusercontent.com/anandnet/Harmony-Music/refs/heads/main/playlist_placeholder.png";

  factory Playlist.fromJson(Map<dynamic, dynamic> json) => Playlist(
      title: json["title"],
      playlistId: json["playlistId"] ?? json["browseId"],
      thumbnailUrl: (json["thumbnails"][0]["url"]).isEmpty
          ? Thumbnail(thumbPlaceholderUrl).extraHigh
          : Thumbnail(json["thumbnails"][0]["url"]).extraHigh,
      description: json["description"] ?? "Playlist",
      songCount: json['itemCount'],
      isPipedPlaylist: json["isPipedPlaylist"] ?? false,
      isCloudPlaylist: json["isCloudPlaylist"] ?? true);

  Map<String, dynamic> toJson() => {
        "title": title,
        "playlistId": playlistId,
        "description": description,
        'thumbnails': [
          {'url': thumbnailUrl}
        ],
        "itemCount": songCount,
        "isPipedPlaylist": isPipedPlaylist,
        "isCloudPlaylist": isCloudPlaylist
      };

  Playlist copyWith({String? title, String? thumbnailUrl}) {
    return Playlist(
        title: title ?? this.title,
        playlistId: playlistId,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        description: description,
        songCount: songCount,
        isPipedPlaylist: isPipedPlaylist,
        isCloudPlaylist: isCloudPlaylist);
  }

  // Converts this object to a MediaItem object.
  // This is used to display the playlist in Android auto.
  MediaItem toMediaItem() {
    return MediaItem(
        id: playlistId,
        title: title,
        artUri: Uri.parse(thumbnailUrl),
        playable: false);
  }

  set newTitle(String title) {
    this.title = title;
  }
}
