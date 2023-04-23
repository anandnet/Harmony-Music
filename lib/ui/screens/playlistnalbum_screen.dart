import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/utils/theme_controller.dart';
import 'package:harmonymusic/ui/widgets/list_widget.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/song_list_shimmer.dart';

import '../../models/playlist.dart';
import '../player/player_controller.dart';
import '../widgets/image_widget.dart';

class PlaylistNAlbumScreen extends StatelessWidget {
  ///PlaylistScreen renders playlist content
  ///
  ///Playlist title,image,songs
  const PlaylistNAlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as List;
    final dynamic content =
        args[0] as bool ? args[1] as Album : args[1] as Playlist;
    final PlayerController playerController = Get.find<PlayerController>();
    final PlayListNAlbumScreenController playListNAlbumScreenController =
        Get.put(PlayListNAlbumScreenController(content, args[0]));
    return Container(
      child: Row(
        children: [
          NavigationRail(
            leading: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).textTheme.titleMedium!.color,
                    ),
                    onPressed: () {
                      Get.nestedKey(ScreenNavigationSetup.id)!
                          .currentState!
                          .pop();
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            selectedIndex: 0, //_selectedIndex,
            minWidth: 60,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              railDestination("Songs"),
              railDestination(""),
            ],
            // selectedIconTheme: IconThemeData(color: Colors.white)
          ),
          Expanded(
              child: Container(
            color: Theme.of(context).canvasColor,
            padding: const EdgeInsets.only(top: 90, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.start,
                ),
                (playListNAlbumScreenController.isAlbum.isFalse &&
                        !content.isCloudPlaylist)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: SizedBox.square(
                            dimension: 200,
                            child: Stack(
                              children: [
                                playListNAlbumScreenController.isAlbum.isTrue
                                    ? ImageWidget(
                                        album: content,
                                        isLargeImage: true,
                                      )
                                    : ImageWidget(
                                        playlist: content,
                                        isLargeImage: true,
                                      ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: InkWell(
                                      onTap: () {
                                        playListNAlbumScreenController
                                            .addNremoveFromLibrary(content,
                                                add:
                                                    playListNAlbumScreenController
                                                        .isAddedToLibrary
                                                        .isFalse);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .canvasColor
                                                .withOpacity(.7),
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10))),
                                        child: Obx(() => Icon(
                                            playListNAlbumScreenController
                                                    .isAddedToLibrary.isFalse
                                                ? Icons.add
                                                : Icons.check)),
                                      )),
                                ),
                              ],
                            )),
                      ),
                Padding(
                  padding: EdgeInsets.only(
                      top: (playListNAlbumScreenController.isAlbum.isFalse &&
                              !content.isCloudPlaylist)
                          ? 0
                          : 10.0),
                  child: Text(
                    playListNAlbumScreenController.isAlbum.isTrue
                        ? content.artists[0]['name'] ?? ""
                        : content.description ?? "",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                (playListNAlbumScreenController.isAlbum.isFalse &&
                        !content.isCloudPlaylist)
                    ? const SizedBox.shrink()
                    : const Divider(),
                (playListNAlbumScreenController.isAlbum.isFalse &&
                        !content.isCloudPlaylist)
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          "Songs",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                Obx(() =>
                    playListNAlbumScreenController.isContentFetched.value
                        ? ListWidget(
                            playListNAlbumScreenController.songList,
                            "Songs",
                            true)
                        : const Expanded(child: SongListShimmer()))
              ],
            ),
          ))
        ],
      ),
    );
  }

  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}
