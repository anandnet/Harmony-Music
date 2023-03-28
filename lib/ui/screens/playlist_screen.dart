import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/screens/playlist_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/song_list_shimmer.dart';

import '../../models/playlist.dart';
import '../player/player_controller.dart';
import '../widgets/image_widget.dart';

class PlayListScreen extends StatelessWidget {
  ///PlaylistScreen renders playlist content
  ///
  ///Playlist title,image,songs
  const PlayListScreen({super.key});
  static const routeName = '/playlistScreen';

  @override
  Widget build(BuildContext context) {
    final Playlist playlist = Get.arguments as Playlist;
    final PlayerController playerController = Get.find<PlayerController>();
    final PlayListScreenController playListScreenController =
        Get.put(PlayListScreenController(playlist.playlistId));
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
                  playlist.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox.square(
                    dimension: 200,
                    child: ImageWidget(
                      playlist: playlist,
                      isLargeImage: true,
                    )),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  playlist.description ?? "",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Divider(),
                Text(
                  "Songs",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                    child: Obx(() => playListScreenController
                            .isContentFetched.value
                        ? ListView.builder(
                            itemCount: playListScreenController.songList.length,
                            padding: const EdgeInsets.only(left: 5, bottom: 85),
                            itemBuilder: (_, index) => ListTile(
                                  onTap: () {
                                    playerController.playPlayListSong([
                                      ...playListScreenController.songList.value
                                    ], index);
                                  },
                                  contentPadding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 30),
                                  leading: SizedBox.square(
                                      dimension: 50,
                                      child: ImageWidget(
                                        song: playListScreenController
                                            .songList[index],
                                      )),
                                  title: Text(
                                    playListScreenController
                                        .songList[index].title,
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Text(
                                    "${playListScreenController.songList[index].artist}",
                                    maxLines: 1,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  trailing: Text(
                                    playListScreenController
                                            .songList[index].extras!['length'] ??
                                        "",
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ))
                        : const SongListShimmer()))
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
