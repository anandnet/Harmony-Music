import '../models/thumbnail.dart';

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
      subscribers: (json['subscribers']) == null
          ? ""
          : (json['subscribers']).runtimeType.toString() == "String"
              ? json['subscribers']
              : json['subscribers']['text'],
      thumbnailUrl: Thumbnail(json["thumbnails"][0]["url"]).high);

  Map<String, dynamic> toJson() => {
        'artist': name,
        'browseId': browseId,
        'radioId': radioId,
        'subscribers': subscribers,
        'thumbnails': [
          {'url': thumbnailUrl}
        ]
      };
}

class ArtistContent{
  ArtistContent(this.content,{this.title = "Artists"});
  final List<Artist> content;
  final String title;
}
