import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/services/downloader.dart';
import 'package:harmonymusic/utils/helper.dart';

import '../../widgets/loader.dart';
import '../../widgets/modification_list.dart';
import '../Library/library_controller.dart';
import '/ui/navigator.dart';
import 'playlistnalbum_screen_controller.dart';
import '/ui/widgets/create_playlist_dialog.dart';
import '/ui/widgets/list_widget.dart';
import '/ui/widgets/shimmer_widgets/song_list_shimmer.dart';
import '/ui/widgets/snackbar.dart';
import '/ui/widgets/sort_widget.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/playlist.dart';
import '../../player/player_controller.dart';
import '../../widgets/image_widget.dart';

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

    return Container(
      color: Theme.of(context).canvasColor,
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 73.0),
                child: IconButton(
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
                            width: MediaQuery.of(context).size.width - 170,
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
                                      content.playlistId != "LIBRP" &&
                                      content.playlistId != "SongDownloads") ||
                                  (!playListNAlbumScreenController.isAlbum &&
                                      content.isPipedPlaylist))
                              ? Row(
                                  children: [
                                    !content.isPipedPlaylist
                                        ? GetX<Downloader>(
                                            builder: (controller) {
                                            final id =
                                                playListNAlbumScreenController
                                                        .isAlbum
                                                    ? content.browseId
                                                    : content.playlistId;
                                            return IconButton(
                                              onPressed: () {
                                                if (playListNAlbumScreenController
                                                    .isDownloaded.isTrue) {
                                                  return;
                                                }
                                                controller.downloadPlaylist(
                                                    id,
                                                    playListNAlbumScreenController
                                                        .songList
                                                        .toList());
                                              },
                                              icon: playListNAlbumScreenController
                                                      .isDownloaded.isTrue
                                                  ? const Icon(Icons
                                                      .download_done_rounded)
                                                  : controller.playlistQueue
                                                              .containsKey(
                                                                  id) &&
                                                          controller
                                                                  .currentPlaylistId
                                                                  .toString() ==
                                                              id
                                                      ? Stack(
                                                          children: [
                                                            Center(
                                                                child: Text(
                                                                    "${controller.playlistDownloadingProgress.value}/${playListNAlbumScreenController.songList.length}",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium!
                                                                        .copyWith(
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.bold))),
                                                            const Center(
                                                                child:
                                                                    LoadingIndicator(
                                                              dimension: 30,
                                                            ))
                                                          ],
                                                        )
                                                      : controller.playlistQueue
                                                              .containsKey(id)
                                                          ? const Stack(
                                                              children: [
                                                                Center(
                                                                    child: Icon(
                                                                  Icons
                                                                      .hourglass_bottom_rounded,
                                                                  size: 20,
                                                                )),
                                                                Center(
                                                                    child:
                                                                        LoadingIndicator(
                                                                  dimension: 30,
                                                                ))
                                                              ],
                                                            )
                                                          : const Icon(Icons
                                                              .download_rounded),
                                            );
                                          })
                                        : const SizedBox.shrink(),
                                    IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            constraints: const BoxConstraints(
                                                maxWidth: 500),
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(
                                                          10.0)),
                                            ),
                                            context:
                                                Get.find<PlayerController>()
                                                    .homeScaffoldkey
                                                    .currentState!
                                                    .context,
                                            barrierColor: Colors.transparent
                                                .withAlpha(100),
                                            builder: (context) => SizedBox(
                                              height: 140,
                                              child: Column(
                                                children: [
                                                  ListTile(
                                                    leading: const Icon(
                                                        Icons.edit_rounded),
                                                    title: Text(
                                                        "renamePlaylist".tr),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            CreateNRenamePlaylistPopup(
                                                                renamePlaylist:
                                                                    true,
                                                                playlist:
                                                                    content),
                                                      );
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(
                                                        Icons.delete_rounded),
                                                    title: Text(
                                                        "removePlaylist".tr),
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                                                                    ? "playlistRemovedAlert"
                                                                        .tr
                                                                    : "operationFailed"
                                                                        .tr,
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
                                        icon: const Icon(
                                            Icons.more_vert_rounded)),
                                  ],
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                      (!playListNAlbumScreenController.isAlbum &&
                              !content.isCloudPlaylist)
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Obx(() {
                                return !playListNAlbumScreenController
                                        .isSearchingOn.value
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox.square(
                                              dimension: 200,
                                              child: Stack(
                                                children: [
                                                  playListNAlbumScreenController
                                                          .isAlbum
                                                      ? ImageWidget(
                                                          size: 200,
                                                          album: content,
                                                        )
                                                      : ImageWidget(
                                                          size: 200,
                                                          playlist: content,
                                                        ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 180,
                                                                minWidth: 110),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5),
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .canvasColor
                                                                .withOpacity(
                                                                    .8),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        height: 27,
                                                        //width: 110,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Get.find<
                                                                    PlayerController>()
                                                                .enqueueSongList(
                                                                    playListNAlbumScreenController
                                                                        .songList
                                                                        .toList())
                                                                .whenComplete(() => ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(snackbar(
                                                                        context,
                                                                        "songEnqueueAlert"
                                                                            .tr,
                                                                        size: SanckBarSize
                                                                            .MEDIUM)));
                                                          },
                                                          child: Text(
                                                            "enqueueAll".tr,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .titleSmall,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          // side tool bar
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height:
                                                  playListNAlbumScreenController
                                                          .isAddedToLibrary
                                                          .isFalse
                                                      ? 180
                                                      : 230,
                                              width: 47,
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                      .withOpacity(.7),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  (!playListNAlbumScreenController
                                                              .isAlbum &&
                                                          content
                                                              .isPipedPlaylist)
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
                                                                                ? "albumBookmarkAddAlert".tr
                                                                                : "playlistBookmarkAddAlert".tr
                                                                            : playListNAlbumScreenController.isAlbum
                                                                                ? "albumBookmarkRemoveAlert".tr
                                                                                : "playlistBookmarkRemoveAlert".tr
                                                                        : "operationFailed".tr,
                                                                    size: SanckBarSize.MEDIUM)));
                                                          },
                                                          icon: Icon(
                                                              size: 20,
                                                              playListNAlbumScreenController
                                                                      .isAddedToLibrary
                                                                      .isFalse
                                                                  ? Icons
                                                                      .bookmark_add_rounded
                                                                  : Icons
                                                                      .bookmark_added_rounded)),
                                                  if (playListNAlbumScreenController
                                                      .isAddedToLibrary.isTrue)
                                                    IconButton(
                                                        onPressed: () {
                                                          playListNAlbumScreenController
                                                              .syncPlaylistNAlbumSong();
                                                        },
                                                        icon: const Icon(
                                                            Icons.cloud_sync)),
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
                                                                  "playlistBlacklistAlert"
                                                                      .tr,
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
                                                                          0,
                                                                          2) ==
                                                                  "VL";
                                                          String url =
                                                              "https://youtube.com/playlist?list=";

                                                          url = isPlaylistIdPrefixAvlbl
                                                              ? url +
                                                                  content
                                                                      .playlistId
                                                                      .substring(
                                                                          2)
                                                              : url +
                                                                  content
                                                                      .playlistId;
                                                          Share.share(url);
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.share,
                                                        size: 20,
                                                      )),
                                                  GetX<Downloader>(
                                                      builder: (controller) {
                                                    final id =
                                                        playListNAlbumScreenController
                                                                .isAlbum
                                                            ? content.browseId
                                                            : content
                                                                .playlistId;
                                                    return IconButton(
                                                      onPressed: () {
                                                        if (playListNAlbumScreenController
                                                            .isDownloaded
                                                            .isTrue) {
                                                          return;
                                                        }
                                                        controller.downloadPlaylist(
                                                            id,
                                                            playListNAlbumScreenController
                                                                .songList
                                                                .toList());
                                                      },
                                                      icon: playListNAlbumScreenController
                                                              .isDownloaded
                                                              .isTrue
                                                          ? const Icon(Icons
                                                              .download_done_rounded)
                                                          : controller.playlistQueue
                                                                      .containsKey(
                                                                          id) &&
                                                                  controller
                                                                          .currentPlaylistId
                                                                          .toString() ==
                                                                      id
                                                              ? Stack(
                                                                  children: [
                                                                    Center(
                                                                        child: Text(
                                                                            "${controller.playlistDownloadingProgress.value}/${playListNAlbumScreenController.songList.length}",
                                                                            style:
                                                                                Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.bold))),
                                                                    const Center(
                                                                        child:
                                                                            LoadingIndicator(
                                                                      dimension:
                                                                          30,
                                                                    ))
                                                                  ],
                                                                )
                                                              : controller
                                                                      .playlistQueue
                                                                      .containsKey(
                                                                          id)
                                                                  ? const Stack(
                                                                      children: [
                                                                        Center(
                                                                            child:
                                                                                Icon(
                                                                          Icons
                                                                              .hourglass_bottom_rounded,
                                                                          size:
                                                                              20,
                                                                        )),
                                                                        Center(
                                                                            child:
                                                                                LoadingIndicator(
                                                                          dimension:
                                                                              30,
                                                                        ))
                                                                      ],
                                                                    )
                                                                  : const Icon(Icons
                                                                      .download_rounded),
                                                    );
                                                  }),
                                                  IconButton(
                                                    onPressed: () {
                                                      Get.find<PlayerController>()
                                                        .playPlayListSong(playListNAlbumScreenController.songList, 0);
                                                      if (playListNAlbumScreenController.contentRenderer is Playlist) {
                                                        playListNAlbumScreenController.contentRenderer.updateLastPlayed();
                                                      }
                                                    },
                                                    icon: const Icon(Icons.play_arrow)
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink();
                              }),
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
                                        "${playListNAlbumScreenController.songList.length}",
                                    itemIcon: Icons.music_note_rounded,
                                    titleLeftPadding: 9,
                                    requiredSortTypes: buildSortTypeSet(false, true),
                                    isPlaylistRearrageFeatureRequired:
                                        content.playlistId != "LIBRP" &&
                                            content.playlistId !=
                                                "SongDownloads" &&
                                            content.playlistId != "SongsCache",
                                    isSongDeletetioFeatureRequired:
                                        content.playlistId != "LIBRP",
                                    onSort: (type, ascending) {
                                      playListNAlbumScreenController.onSort(
                                          type, ascending);
                                    },
                                    onSearch:
                                        playListNAlbumScreenController.onSearch,
                                    onSearchClose:
                                        playListNAlbumScreenController
                                            .onSearchClose,
                                    onSearchStart:
                                        playListNAlbumScreenController
                                            .onSearchStart,
                                    startAdditionalOperation:
                                        playListNAlbumScreenController
                                            .startAdditionalOperation,
                                    selectAll: playListNAlbumScreenController
                                        .selectAll,
                                    performAdditionalOperation:
                                        playListNAlbumScreenController
                                            .performAdditionalOperation,
                                    cancelAdditionalOperation:
                                        playListNAlbumScreenController
                                            .cancelAdditionalOperation,
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
                                    "${playListNAlbumScreenController.songList.length}",
                                itemIcon: Icons.music_note_rounded,
                                titleLeftPadding: 9,
                                requiredSortTypes: buildSortTypeSet(false, true),
                                onSort: (type, ascending) {
                                  playListNAlbumScreenController.onSort(
                                      type, ascending);
                                },
                                onSearch:
                                    playListNAlbumScreenController.onSearch,
                                onSearchClose: playListNAlbumScreenController
                                    .onSearchClose,
                                onSearchStart: playListNAlbumScreenController
                                    .onSearchStart,
                                startAdditionalOperation:
                                    playListNAlbumScreenController
                                        .startAdditionalOperation,
                                selectAll:
                                    playListNAlbumScreenController.selectAll,
                                performAdditionalOperation:
                                    playListNAlbumScreenController
                                        .performAdditionalOperation,
                                cancelAdditionalOperation:
                                    playListNAlbumScreenController
                                        .cancelAdditionalOperation,
                              ),
                            ),
                      Obx(() => playListNAlbumScreenController
                              .isContentFetched.value
                          ? Obx(() => playListNAlbumScreenController
                                  .songList.isNotEmpty
                              ? (playListNAlbumScreenController
                                          .additionalOperationMode.value ==
                                      OperationMode.none
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
                                  : ModificationList(
                                      mode: playListNAlbumScreenController
                                          .additionalOperationMode.value,
                                      playListNAlbumScreenController:
                                          playListNAlbumScreenController,
                                    ))
                              : Expanded(
                                  child: Center(
                                    child: Text("emptyPlaylist".tr,
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
