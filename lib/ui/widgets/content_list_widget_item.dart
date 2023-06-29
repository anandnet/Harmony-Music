import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../navigator.dart';
import 'image_widget.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem(
      {super.key, required this.content, this.isLibraryItem = false});

  ///content will be of Type class Album or Playlist
  final dynamic content;
  final bool isLibraryItem;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
            id: ScreenNavigationSetup.id, arguments: [isAlbum, content,false]);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isAlbum
                ? ImageWidget(
                    size: 120,
                    album: content,
                  )
                : content.isCloudPlaylist
                    ? ImageWidget(
                      size: 120,
                        playlist: content,
                      )
                    : Container(
                      height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                            child: Icon(
                          content.playlistId == 'LIBRP'
                              ? Icons.history_rounded
                              : content.playlistId == 'LIBFAV'
                                  ? Icons.favorite_rounded
                                  : content.playlistId == 'SongsCache'
                                      ? Icons.flight_rounded
                                      : Icons.playlist_play_rounded,
                          color: Colors.white,
                          size: 40,
                        ))),
            const SizedBox(height: 5),
            Text(
              content.title,
              // overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              isAlbum
                  ? isLibraryItem ? "":"${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                  : isLibraryItem
                      ? ""
                      : content.description ?? "",
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
