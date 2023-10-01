import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/loader.dart';
import '/ui/utils/home_library_controller.dart';
import '/ui/navigator.dart';
import '/ui/screens/playlistnalbum_screen_controller.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '/ui/widgets/list_widget.dart';
import '/ui/widgets/shimmer_widgets/song_list_shimmer.dart';
import '/ui/widgets/snackbar.dart';
import '/ui/widgets/sort_widget.dart';
import 'package:share_plus/share_plus.dart';
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
    final tag = key.hashCode.toString();
    final PlayListNAlbumScreenController playListNAlbumScreenController =
        (Get.isRegistered<PlayListNAlbumScreenController>(tag: tag))
            ? Get.find<PlayListNAlbumScreenController>(tag: tag)
            : Get.put(PlayListNAlbumScreenController(), tag: tag);

    return SizedBox(
      child: Row(
        children: [
          NavigationRail(
            leading: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Theme.of(context).textTheme.titleMedium!.color,
                  ),
                  onPressed: () {
                    Get.nestedKey(ScreenNavigationSetup.id)!
                        .currentState!
                        .pop();
                  },
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
          Obx(() {
            if (playListNAlbumScreenController.isContentFetched.isFalse) {
              return const Expanded(
                  child: Center(
                child: LoadingIndicator(),
              ));
            } else {
              final content = playListNAlbumScreenController.contentRenderer;
              return Expanded(
                child: Container(
                  color: Theme.of(context).canvasColor,
                  padding: const EdgeInsets.only(top: 73, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 120,
                            child: Text(
                              content.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ((!playListNAlbumScreenController.isAlbum &&
                                      !content.isCloudPlaylist &&
                                      content.playlistId != "LIBFAV" &&
                                      content.playlistId != "SongsCache" &&
                                      content.playlistId != "LIBRP") ||
                                  (!playListNAlbumScreenController.isAlbum &&
                                      content.isPipedPlaylist))
                              ? IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: Get.find<PlayerController>()
                                          .homeScaffoldkey
                                          .currentState!
                                          .context,
                                      barrierColor:
                                          Colors.transparent.withAlpha(100),
                                      builder: (context) => SizedBox(
                                        height: 140,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.edit_rounded),
                                              title:
                                                  const Text("Rename playlist"),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      CreateNRenamePlaylistPopup(
                                                          renamePlaylist: true,
                                                          playlist: content),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(
                                                  Icons.delete_rounded),
                                              title:
                                                  const Text("Remove playlist"),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                playListNAlbumScreenController
                                                    .addNremoveFromLibrary(
                                                        content,
                                                        add: false)
                                                    .then((value) {
                                                  Get.nestedKey(
                                                          ScreenNavigationSetup
                                                              .id)!
                                                      .currentState!
                                                      .pop();
                                                  ScaffoldMessenger.of(
                                                          Get.context!)
                                                      .showSnackBar(snackbar(
                                                          Get.context!,
                                                          value
                                                              ? "Playlist removed!"
                                                              : "Operation failed",
                                                          size: SanckBarSize
                                                              .MEDIUM));
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.more_vert_rounded))
                              : const SizedBox.shrink()
                        ],
                      ),
                      (!playListNAlbumScreenController.isAlbum &&
                              !content.isCloudPlaylist)
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child:Obx(() => !playListNAlbumScreenController.isSearchingOn.value ? SizedBox.square(
                                  dimension: 200,
                                  child: Stack(
                                    children: [
                                      playListNAlbumScreenController.isAlbum
                                          ? ImageWidget(
                                              size: 200,
                                              album: content,
                                            )
                                          : ImageWidget(
                                              size: 200,
                                              playlist: content,
                                            ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: 80,
                                          width: 40,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .canvasColor
                                                  .withOpacity(.7),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10))),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              (!playListNAlbumScreenController
                                                          .isAlbum &&
                                                      content.isPipedPlaylist)
                                                  ? const SizedBox.shrink()
                                                  : IconButton(
                                                      visualDensity:
                                                          const VisualDensity(
                                                              vertical: -4),
                                                      splashRadius: 10,
                                                      onPressed: () {
                                                        final add =
                                                            playListNAlbumScreenController
                                                                .isAddedToLibrary
                                                                .isFalse;
                                                        playListNAlbumScreenController
                                                            .addNremoveFromLibrary(
                                                                content,
                                                                add: add)
                                                            .then((value) => ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                                                context,
                                                                value
                                                                    ? add
                                                                        ? playListNAlbumScreenController.isAlbum
                                                                            ? "Album bookmarked !"
                                                                            : "Playlist bookmarked!"
                                                                        : playListNAlbumScreenController.isAlbum
                                                                            ? "Album bookmark removed!"
                                                                            : "Playlist bookmark removed!"
                                                                    : "Operation failed",
                                                                size: SanckBarSize.MEDIUM)));
                                                      },
                                                      icon: Obx(() => Icon(
                                                          size: 20,
                                                          playListNAlbumScreenController
                                                                  .isAddedToLibrary
                                                                  .isFalse
                                                              ? Icons
                                                                  .bookmark_add_rounded
                                                              : Icons
                                                                  .bookmark_added_rounded)),
                                                    ),
                                              if (!playListNAlbumScreenController
                                                      .isAlbum &&
                                                  content.isPipedPlaylist)
                                                IconButton(
                                                    icon: const Icon(
                                                      Icons.block,
                                                      size: 20,
                                                    ),
                                                    visualDensity:
                                                        const VisualDensity(
                                                            vertical: -4),
                                                    splashRadius: 10,
                                                    onPressed: () {
                                                      Get.nestedKey(
                                                              ScreenNavigationSetup
                                                                  .id)!
                                                          .currentState!
                                                          .pop();
                                                      Get.find<
                                                              LibraryPlaylistsController>()
                                                          .blacklistPipedPlaylist(
                                                              content
                                                                  as Playlist);
                                                      ScaffoldMessenger.of(
                                                              Get.context!)
                                                          .showSnackBar(snackbar(
                                                              Get.context!,
                                                              "Playlist blacklisted!",
                                                              size: SanckBarSize
                                                                  .MEDIUM));
                                                    }),
                                              IconButton(
                                                  visualDensity:
                                                      const VisualDensity(
                                                          vertical: -3),
                                                  splashRadius: 10,
                                                  onPressed: () {
                                                    if (playListNAlbumScreenController
                                                        .isAlbum) {
                                                      Share.share(
                                                          "https://youtube.com/playlist?list=${content.audioPlaylistId}");
                                                    } else if (content
                                                        .isPipedPlaylist) {
                                                      Share.share(
                                                          "https://piped.video/playlist?list=${content.playlistId}");
                                                    } else {
                                                      final isPlaylistIdPrefixAvlbl =
                                                          content.playlistId
                                                                  .substring(
                                                                      0, 2) ==
                                                              "VL";
                                                      String url =
                                                          "https://youtube.com/playlist?list=";

                                                      url = isPlaylistIdPrefixAvlbl
                                                          ? url +
                                                              content.playlistId
                                                                  .substring(2)
                                                          : url +
                                                              content
                                                                  .playlistId;
                                                      Share.share(url);
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.share,
                                                    size: 20,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .canvasColor
                                                    .withOpacity(.7),
                                                borderRadius:
                                                    BorderRadius.circular(15)),
                                            height: 27,
                                            width: 110,
                                            child: InkWell(
                                              onTap: () {
                                                Get.find<PlayerController>()
                                                    .enqueueSongList(
                                                        playListNAlbumScreenController
                                                            .songList
                                                            .toList())
                                                    .whenComplete(() =>
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(snackbar(
                                                                context,
                                                                "Songs enqueued!",
                                                                size: SanckBarSize
                                                                    .MEDIUM)));
                                              },
                                              child: const Center(
                                                  child: Text(
                                                "Enqueue all",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  )): const SizedBox.shrink()),
                            ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: (!playListNAlbumScreenController.isAlbum &&
                                      !content.isCloudPlaylist)
                                  ? 0
                                  : 10.0),
                          child: (playListNAlbumScreenController.isAlbum ||
                                  (!playListNAlbumScreenController.isAlbum &&
                                      content.isCloudPlaylist))
                              ? Text(
                                  playListNAlbumScreenController.isAlbum
                                      ? content.artists[0]['name'] ?? ""
                                      : content.description ?? "",
                                  style: Theme.of(context).textTheme.titleSmall,
                                )
                                
                              : Obx(
                                  () => SortWidget(
                                    tag: playListNAlbumScreenController.isAlbum
                                        ? content.browseId
                                        : content.playlistId,
                                    isSearchFeatureRequired: true,
                                    itemCountTitle:
                                        "${playListNAlbumScreenController.songList.length} songs",
                                    titleLeftPadding: 9,
                                    isDurationOptionRequired: true,
                                    onSort: (a, b, c, d) {
                                      playListNAlbumScreenController.onSort(
                                          a, c, d);
                                    },
                                    onSearch:
                                        playListNAlbumScreenController.onSearch,
                                    onSearchClose:
                                        playListNAlbumScreenController
                                            .onSearchClose,
                                    onSearchStart:
                                        playListNAlbumScreenController
                                            .onSearchStart,
                                  ),
                                )),
                      (!playListNAlbumScreenController.isAlbum &&
                              !content.isCloudPlaylist)
                          ? const SizedBox.shrink()
                          : const Divider(),
                      (!playListNAlbumScreenController.isAlbum &&
                              !content.isCloudPlaylist)
                          ? const SizedBox.shrink()
                          : Obx(
                              () => SortWidget(
                                tag: playListNAlbumScreenController.isAlbum
                                    ? content.browseId
                                    : content.playlistId,
                                isSearchFeatureRequired: true,
                                itemCountTitle:
                                    "${playListNAlbumScreenController.songList.length} songs",
                                titleLeftPadding: 9,
                                isDurationOptionRequired: true,
                                onSort: (a, b, c, d) {
                                  playListNAlbumScreenController.onSort(
                                      a, c, d);
                                },
                                onSearch:
                                    playListNAlbumScreenController.onSearch,
                                onSearchClose: playListNAlbumScreenController
                                    .onSearchClose,
                                onSearchStart: playListNAlbumScreenController
                                    .onSearchStart,
                              ),
                            ),
                      Obx(() => playListNAlbumScreenController
                              .isContentFetched.value
                          ? Obx(() =>
                              playListNAlbumScreenController.songList.isNotEmpty
                                  ? ListWidget(
                                      playListNAlbumScreenController.songList
                                          .toList(),
                                      "Songs",
                                      true,
                                      isPlaylist: true,
                                      playlist: !playListNAlbumScreenController
                                              .isAlbum
                                          ? content as Playlist
                                          : null,
                                    )
                                  : Expanded(
                                      child: Center(
                                        child: Text("Empty playlist !",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall),
                                      ),
                                    ))
                          : const Expanded(child: SongListShimmer()))
                    ],
                  ),
                ),
              );
            }
          })
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
