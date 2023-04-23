import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';

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
      onTap: () {
        Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
            id: ScreenNavigationSetup.id, arguments: [isAlbum, content]);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: isAlbum
                  ? ImageWidget(
                      album: content,
                      isMediumImage: true,
                    )
                  : content.isCloudPlaylist
                      ? ImageWidget(
                          playlist: content,
                          isMediumImage: true,
                        )
                      : Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .canvasColor
                                  .withLightness(0.6),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                              child: Icon(
                            content.playlistId == 'LIBRP'
                                ? Icons.history_rounded
                                : content.playlistId == 'LIBFAV'
                                    ? Icons.favorite
                                    : Icons.flight,color: Colors.white,
                            size: 40,
                          ))),
            ),
            const SizedBox(height: 5),
            Text(
              content.title,
              // overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              isAlbum
                  ? content.artists[0]['name'] ?? ""
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
