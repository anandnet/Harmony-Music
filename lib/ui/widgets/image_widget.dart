import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/song.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/album.dart';
import '../../models/playlist.dart';
import 'shimmer_widgets/basic_container.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, this.song, this.playlist, this.album});
  final Song? song;
  final Playlist? playlist;
  final Album? album;

  @override
  Widget build(BuildContext context) {
    String imageUrl = song != null
        ? song!.thumbnailUrl
        : playlist != null
            ? playlist!.thumbnailUrl
            : album != null
                ? album!.thumbnailUrl
                : "";
    String cacheKey = song != null
        ? "${song!.songId}_song"
        : playlist != null
            ? "${playlist!.playlistId}_playlist"
            : album != null
                ? "${album!.browseId}_album"
                : "";
    return GetPlatform.isWeb
        ? Image.network(
            imageUrl,
            fit: BoxFit.fitHeight,
          )
        : ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CachedNetworkImage(
              cacheKey: cacheKey,
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              progressIndicatorBuilder: ((_, __, ___) => Shimmer.fromColors(
                  baseColor: Colors.grey[500]!,
                  highlightColor: Colors.grey[300]!,
                  enabled: true,
                  direction: ShimmerDirection.ltr,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white54,
                    ),
                  ))),
            ),
        );
  }
}
