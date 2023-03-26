import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/ui/screens/playlist_screen.dart';

import '../navigator.dart';
import 'image_widget.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem({super.key, required this.content});

  ///content will be of Type class Album or Playlist
  final dynamic content;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      onTap: !isAlbum
          ? () {
              Get.toNamed("/playlistScreen",
                  id: ScreenNavigationSetup.id, arguments: content);
            }
          : () {},
      child: Container(
        width: 140,
        padding: const EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: isAlbum
                  ? ImageWidget(
                      album: content,
                      isMediumImage: true,
                    )
                  : ImageWidget(
                      playlist: content,
                      isMediumImage: true,
                    ),
            ),
            const SizedBox(height: 5),
            Text(
              content.title,
              // overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              isAlbum ? content.artist ?? "" : content.description ?? "",
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
