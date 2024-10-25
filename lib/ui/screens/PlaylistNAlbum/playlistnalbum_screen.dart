import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/components/playlist_content_section.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/components/playlist_header_section.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';

class PlaylistNAlbumScreen extends StatelessWidget {
  ///PlaylistScreen renders playlist content
  ///
  ///Playlist title,image,songs
  const PlaylistNAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tag = key.hashCode.toString();
    final topPadding = context.isLandscape ? 50.0 : 80.0;
    final playListNAlbumScreenController = (Get.isRegistered<PlayListNAlbumScreenController>(tag: tag))
        ? Get.find<PlayListNAlbumScreenController>(tag: tag)
        : Get.put(PlayListNAlbumScreenController(), tag: tag);

    return ColoredBox(
      color: Theme.of(context).canvasColor,
      child: row.children([
        sizedBox.w110.child(
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: topPadding),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).textTheme.titleMedium!.color,
                ),
                onPressed: () {
                  Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                },
              ),
            ),
          ),
        ),
        Obx(() {
          if (playListNAlbumScreenController.isContentFetched.isFalse) {
            return const Expanded(
                child: Center(
              child: LoadingIndicator(),
            ));
          } else {
            final content = playListNAlbumScreenController.contentRenderer;
            final isOfflinePlaylist = !playListNAlbumScreenController.isAlbum;
            final isWiderScreen = MediaQuery.of(context).size.width > 750;
            return Expanded(
              child: Container(
                color: Theme.of(context).canvasColor,
                padding: EdgeInsets.only(top: topPadding, left: 10),
                child: isOfflinePlaylist
                    ? column.crossStart.children([
                        OfflinePlaylistHeader(content: content, tag: tag),
                        PlaylistContentSection(content: content, tag: tag),
                      ])
                    : isWiderScreen
                        ? row.children([
                            OnlinePlaylistHeader(content: content, tag: tag),
                            const SizedBox(width: 30),
                            PlaylistContentSection(content: content, tag: tag),
                          ])
                        : column.crossStart.children([
                            OnlinePlaylistHeader(
                              content: content,
                              tag: tag,
                              enableSeparator: !isWiderScreen,
                            ),
                            PlaylistContentSection(content: content, tag: tag),
                          ]),
              ),
            );
          }
        })
      ]),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}
