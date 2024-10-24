import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/services/downloader.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/create_playlist_dialog.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistDescription extends StatelessWidget {
  const PlaylistDescription({
    required this.description,
    super.key,
    this.enableSeparator = false,
  });

  final bool enableSeparator;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            description,
            maxLines: 2,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (enableSeparator) const Divider()
      ],
    );
  }
}

class OnlinePlaylistHeader extends StatelessWidget {
  const OnlinePlaylistHeader({
    required this.content,
    required this.tag,
    super.key,
    this.enableSeparator = false,
  });

  final dynamic content;
  final String tag;
  final bool enableSeparator;

  @override
  Widget build(BuildContext context) {
    final playListNAlbumScreenController = Get.find<PlayListNAlbumScreenController>(tag: tag);
    return (!playListNAlbumScreenController.isAlbum && !content.isCloudPlaylist)
        ? const SizedBox.shrink()
        : padding.pt22.child(
            Obx(() {
              return !playListNAlbumScreenController.isSearchingOn.value
                  ? column.crossStart.children([
                      row.crossStart.children([
                        SizedBox.square(
                            dimension: 200,
                            child: Stack(
                              children: [
                                if (playListNAlbumScreenController.isAlbum)
                                  ImageWidget(
                                    size: 200,
                                    album: content,
                                  )
                                else
                                  ImageWidget(
                                    size: 200,
                                    playlist: content,
                                  ),
                                padding.p16.child(
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 180, minWidth: 110),
                                      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor.withOpacity(.8),
                                          borderRadius: BorderRadius.circular(15)),
                                      height: 27,
                                      child: InkWell(
                                        onTap: () {
                                          Get.find<PlayerController>()
                                              .enqueueSongList(playListNAlbumScreenController.songList.toList())
                                              .whenComplete(() {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar(context, 'songEnqueueAlert'.tr));
                                            }
                                          });
                                        },
                                        child: Text(
                                          'enqueueAll'.tr,
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(width: 5),
                        // side tool bar
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: playListNAlbumScreenController.isAddedToLibrary.isFalse ? 130 : 180,
                            width: 47,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(.7),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                )),
                            child: column.spaceAround.children([
                              if (!playListNAlbumScreenController.isAlbum && content.isPipedPlaylist)
                                const SizedBox.shrink()
                              else
                                IconButton(
                                  visualDensity: const VisualDensity(vertical: -4),
                                  splashRadius: 10,
                                  onPressed: () {
                                    final add = playListNAlbumScreenController.isAddedToLibrary.isFalse;
                                    playListNAlbumScreenController
                                        .addNremoveFromLibrary(content, add: add)
                                        .then((value) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                          context,
                                          value
                                              ? add
                                                  ? playListNAlbumScreenController.isAlbum
                                                      ? 'albumBookmarkAddAlert'.tr
                                                      : 'playlistBookmarkAddAlert'.tr
                                                  : playListNAlbumScreenController.isAlbum
                                                      ? 'albumBookmarkRemoveAlert'.tr
                                                      : 'playlistBookmarkRemoveAlert'.tr
                                              : 'operationFailed'.tr));
                                    });
                                  },
                                  icon: Icon(
                                      size: 20,
                                      playListNAlbumScreenController.isAddedToLibrary.isFalse
                                          ? Icons.bookmark_add_rounded
                                          : Icons.bookmark_added_rounded),
                                ),
                              if (playListNAlbumScreenController.isAddedToLibrary.isTrue)
                                IconButton(
                                    onPressed: playListNAlbumScreenController.syncPlaylistNAlbumSong,
                                    icon: const Icon(Icons.cloud_sync)),
                              if (!playListNAlbumScreenController.isAlbum && content.isPipedPlaylist)
                                IconButton(
                                    icon: Icons.block.icon.s42.mk,
                                    visualDensity: const VisualDensity(vertical: -4),
                                    splashRadius: 10,
                                    onPressed: () {
                                      Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                                      Get.find<LibraryPlaylistsController>()
                                          .blacklistPipedPlaylist(content as Playlist);
                                      ScaffoldMessenger.of(Get.context!)
                                          .showSnackBar(snackbar(Get.context!, 'playlistBlacklistAlert'.tr));
                                    }),
                              IconButton(
                                visualDensity: const VisualDensity(vertical: -3),
                                splashRadius: 10,
                                onPressed: () {
                                  if (playListNAlbumScreenController.isAlbum) {
                                    Share.share('https://youtube.com/playlist?list=${content.audioPlaylistId}');
                                  } else if (content.isPipedPlaylist) {
                                    Share.share('https://piped.video/playlist?list=${content.playlistId}');
                                  } else {
                                    final isPlaylistIdPrefixAvlbl = content.playlistId.substring(0, 2) == 'VL';
                                    var url = 'https://youtube.com/playlist?list=';

                                    url = isPlaylistIdPrefixAvlbl
                                        ? url + content.playlistId.substring(2)
                                        : url + content.playlistId;
                                    Share.share(url);
                                  }
                                },
                                icon: Icons.share.icon.s42.mk,
                              ),
                              GetX<Downloader>(builder: (controller) {
                                final id =
                                    playListNAlbumScreenController.isAlbum ? content.browseId : content.playlistId;
                                return IconButton(
                                  onPressed: () {
                                    if (playListNAlbumScreenController.isDownloaded.isTrue) {
                                      return;
                                    }
                                    controller.downloadPlaylist(id, playListNAlbumScreenController.songList.toList());
                                  },
                                  icon: playListNAlbumScreenController.isDownloaded.isTrue
                                      // ? const Icon(Icons.download_done_rounded)
                                      ? Icons.download_done_rounded.icon.mk
                                      : controller.playlistQueue.containsKey(id) &&
                                              controller.currentPlaylistId.toString() == id
                                          ? Stack(
                                              children: [
                                                Center(
                                                    child: Text(
                                                        '${controller.playlistDownloadingProgress.value}/${playListNAlbumScreenController.songList.length}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium!
                                                            .copyWith(fontSize: 10, fontWeight: FontWeight.bold))),
                                                const Center(
                                                    child: LoadingIndicator(
                                                  dimension: 30,
                                                ))
                                              ],
                                            )
                                          : controller.playlistQueue.containsKey(id)
                                              ? const Stack(
                                                  children: [
                                                    Center(
                                                      child: Icon(
                                                        Icons.hourglass_bottom_rounded,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    Center(
                                                        child: LoadingIndicator(
                                                      dimension: 30,
                                                    ))
                                                  ],
                                                )
                                              : Icons.download_rounded.icon.mk,
                                );
                                // : Text('123'));
                              })
                            ]),
                          ),
                        ),
                      ]),
                      padding.pt16.child(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            content.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: PlaylistDescription(
                          description: content.description,
                          enableSeparator: enableSeparator,
                        ),
                      )
                    ])
                  : const SizedBox.shrink();
            }),
          );
  }
}

class OfflinePlaylistHeader extends StatelessWidget {
  const OfflinePlaylistHeader({
    required this.content,
    required this.tag,
    super.key,
  });

  final dynamic content;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final playListNAlbumScreenController = Get.find<PlayListNAlbumScreenController>(tag: tag);
    return row.spaceBetween.children([
      SizedBox(
        width: MediaQuery.of(context).size.width - 170,
        child: Text(
          content.title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if ((!playListNAlbumScreenController.isAlbum &&
              !content.isCloudPlaylist &&
              content.playlistId != 'LIBFAV' &&
              content.playlistId != 'SongsCache' &&
              content.playlistId != 'LIBRP' &&
              content.playlistId != 'SongDownloads') ||
          (!playListNAlbumScreenController.isAlbum && content.isPipedPlaylist))
        row.children([
          if (!content.isPipedPlaylist)
            GetX<Downloader>(builder: (controller) {
              final id = playListNAlbumScreenController.isAlbum ? content.browseId : content.playlistId;
              return IconButton(
                onPressed: () {
                  if (playListNAlbumScreenController.isDownloaded.isTrue) {
                    return;
                  }
                  controller.downloadPlaylist(id, playListNAlbumScreenController.songList.toList());
                },
                icon: playListNAlbumScreenController.isDownloaded.isTrue
                    ? const Icon(Icons.download_done_rounded)
                    : controller.playlistQueue.containsKey(id) && controller.currentPlaylistId.toString() == id
                        ? Stack(
                            children: [
                              Center(
                                  child: Text(
                                      '${controller.playlistDownloadingProgress.value}/${playListNAlbumScreenController.songList.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(fontSize: 10, fontWeight: FontWeight.bold))),
                              const Center(
                                  child: LoadingIndicator(
                                dimension: 30,
                              ))
                            ],
                          )
                        : controller.playlistQueue.containsKey(id)
                            ? const Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.hourglass_bottom_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  Center(
                                      child: LoadingIndicator(
                                    dimension: 30,
                                  ))
                                ],
                              )
                            : Icons.download_rounded.icon.mk,
              );
            })
          else
            const SizedBox.shrink(),
          IconButton(
            icon: Icons.more_vert_rounded.icon.mk,
            onPressed: () {
              showModalBottomSheet(
                constraints: const BoxConstraints(maxWidth: 500),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                context: Get.find<PlayerController>().homeScaffoldKey.currentState!.context,
                barrierColor: Colors.transparent.withAlpha(100),
                builder: (context) {
                  return sizedBox.h260.child(
                    column.children([
                      ListTile(
                        leading: Icons.edit_rounded.icon.mk,
                        title: 'renamePlaylist'.tr.text.mk,
                        onTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => CreateNRenamePlaylistPopup(
                              renamePlaylist: true,
                              playlist: content,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icons.delete_rounded.icon.mk,
                        title: 'removePlaylist'.tr.text.mk,
                        onTap: () {
                          Navigator.of(context).pop();
                          playListNAlbumScreenController.addNremoveFromLibrary(content, add: false).then((value) {
                            Get.nestedKey(ScreenNavigationSetup.id)!.currentState!.pop();
                            ScaffoldMessenger.of(Get.context!).showSnackBar(
                                snackbar(Get.context!, value ? 'playlistRemovedAlert'.tr : 'operationFailed'.tr));
                          });
                        },
                      )
                    ]),
                  );
                },
              );
            },
          )
        ])
      else
        const SizedBox.shrink()
    ]);
  }
}
