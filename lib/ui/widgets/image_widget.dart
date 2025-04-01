import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../screens/Settings/settings_screen_controller.dart';
import '/models/artist.dart';
import '../../models/album.dart';
import '../../models/playlist.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    this.song,
    this.playlist,
    this.album,
    this.artist,
    required this.size,
    this.isPlayerArtImage = false,
  });
  final MediaItem? song;
  final Playlist? playlist;
  final Album? album;
  final bool isPlayerArtImage;
  final Artist? artist;
  final double size;

  @override
  Widget build(BuildContext context) {
    String imageUrl = song != null
        ? song!.artUri.toString()
        : playlist != null
            ? playlist!.thumbnailUrl
            : album != null
                ? album!.thumbnailUrl
                : artist != null
                    ? artist!.thumbnailUrl
                    : "";
    // String cacheKey = song != null
    //     ? "${song!.id}_song"
    //     : playlist != null
    //         ? "${playlist!.playlistId}_playlist"
    //         : album != null
    //             ? "${album!.browseId}_album"
    //             : artist != null
    //                 ? "${artist!.browseId}_artist"
    //                 : "";

    /// only valid for offline songs
    final bool offlineAvailable =
        song != null && (song?.extras?["url"] ?? "").contains("file");

    return Container(
      height: size,
      width: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: artist != null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: artist != null ? null : BorderRadius.circular(5),
      ),
      child: offlineAvailable
          ? Image.file(
              File(
                  "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${song!.id}.png"),
              height: size,
              width: size,
              fit: BoxFit.cover,
            )
          : CachedNetworkImage(
              height: size,
              width: size,
              memCacheHeight: (song != null && !isPlayerArtImage) ? 140 : null,
              //memCacheWidth: (song != null && !isPlayerArtImage)? 140 : null,
              //cacheKey: cacheKey,
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) {
                return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape:
                          artist != null ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius:
                          artist != null ? null : BorderRadius.circular(10),
                    ),
                    child: Image.asset(
                        "assets/icons/${song != null ? "song" : artist != null ? "artist" : "album"}.png"));
              },
              progressIndicatorBuilder: ((_, __, ___) => Shimmer.fromColors(
                  baseColor: Colors.grey[500]!,
                  highlightColor: Colors.grey[300]!,
                  enabled: true,
                  direction: ShimmerDirection.ltr,
                  child: Container(
                    decoration: BoxDecoration(
                      shape:
                          artist != null ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius:
                          artist != null ? null : BorderRadius.circular(10),
                      color: Colors.white54,
                    ),
                  ))),
            ),
    );
  }
}
