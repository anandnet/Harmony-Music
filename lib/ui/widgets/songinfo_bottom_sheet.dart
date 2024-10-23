import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/services/piped_service.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/add_to_playlist.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';
import 'package:harmonymusic/ui/widgets/sleep_timer_bottom_sheet.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:harmonymusic/ui/widgets/song_download_btn.dart';
import 'package:harmonymusic/ui/widgets/song_info_dialog.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SongInfoBottomSheet extends StatelessWidget {
  const SongInfoBottomSheet(
    this.song, {
    super.key,
    this.playlist,
    this.calledFromPlayer = false,
    this.calledFromQueue = false,
  });

  final MediaItem song;
  final Playlist? playlist;
  final bool calledFromPlayer;
  final bool calledFromQueue;

  @override
  Widget build(BuildContext context) {
    final songInfoController = Get.put(SongInfoController(song, calledFromPlayer));
    final playerController = Get.find<PlayerController>();
    return Padding(
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
      child: SingleChildScrollView(
        child: column.min.children([
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15, top: 7, right: 10),
            leading: ImageWidget(song: song, size: 50),
            title: song.title.text.maxLine1.mk,
            subtitle: song.artist!.text.mk,
            trailing: sizedBox.w200.child(
              row.spaceEvenly.children([
                if (calledFromPlayer)
                  IconButton(
                      onPressed: () => showDialog(
                            context: context,
                            builder: (context) =>
                                SongInfoDialog(song: song, isDownloaded: songInfoController.isDownloaded.isTrue),
                          ),
                      icon: Icon(
                        Icons.info,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      ))
                else
                  IconButton(
                      onPressed: songInfoController.toggleFav,
                      icon: Obx(() => Icon(
                            songInfoController.isCurrentSongFav.isFalse
                                ? Icons.favorite_border_rounded
                                : Icons.favorite_rounded,
                            color: Theme.of(context).textTheme.titleMedium!.color,
                          ))),
                SongDownloadButton(
                  song_: song,
                  isDownloadingDoneCallback: songInfoController.setDownloadStatus,
                )
              ]),
            ),
            // trailing: SizedBox(
          ),
          const Divider(),
          ListTile(
            visualDensity: const VisualDensity(vertical: -1),
            leading: Icons.sensors_rounded.icon.mk,
            title: 'startRadio'.tr.text.mk,
            onTap: () {
              Navigator.of(context).pop();
              playerController.startRadio(song);
            },
          ),
          if (calledFromPlayer || calledFromQueue)
            const SizedBox.shrink()
          else
            ListTile(
              visualDensity: const VisualDensity(vertical: -1),
              leading: Icons.playlist_play_rounded.icon.mk,
              title: 'playNext'.tr.text.mk,
              onTap: () {
                Navigator.of(context).pop();
                playerController.playNext(song);
                ScaffoldMessenger.of(context)
                    .showSnackBar(snackbar(context, "${"playnextMsg".tr} ${song.title}", size: SanckBarSize.BIG));
              },
            ),
          ListTile(
            visualDensity: const VisualDensity(vertical: -1),
            leading: Icons.playlist_add_rounded.icon.mk,
            title: 'addToPlaylist'.tr.text.mk,
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AddToPlaylist([song]),
              ).whenComplete(() => Get.delete<AddToPlaylistController>());
            },
          ),
          if (calledFromPlayer || calledFromQueue)
            const SizedBox.shrink()
          else
            ListTile(
              visualDensity: const VisualDensity(vertical: -1),
              leading: Icons.merge_rounded.icon.mk,
              title: 'enqueueSong'.tr.text.mk,
              onTap: () {
                playerController.enqueueSong(song).whenComplete(() {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(snackbar(context, 'songEnqueueAlert'.tr));
                });
                Navigator.of(context).pop();
              },
            ),
          if (song.extras!['album'] != null)
            ListTile(
              visualDensity: const VisualDensity(vertical: -1),
              leading: Icons.album_rounded.icon.mk,
              title: 'goToAlbum'.tr.text.mk,
              onTap: () {
                Navigator.of(context).pop();
                if (calledFromPlayer) {
                  playerController.playerPanelController.close();
                }
                if (calledFromQueue) {
                  playerController.playerPanelController.close();
                }
                Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                    id: ScreenNavigationSetup.id, arguments: [true, song.extras!['album']['id'], true]);
              },
            )
          else
            const SizedBox.shrink(),
          ...artistWidgetList(song, context),
          if ((playlist != null && !playlist!.isCloudPlaylist && !(playlist!.playlistId == 'LIBRP')) ||
              (playlist != null && playlist!.isPipedPlaylist))
            ListTile(
              visualDensity: const VisualDensity(vertical: -1),
              leading: Icons.delete_rounded.icon.mk,
              title: playlist!.title == 'Library Songs' ? 'removeFromLib'.tr.text.mk : 'removeFromPlaylist'.tr.text.mk,
              onTap: () {
                Navigator.of(context).pop();
                songInfoController.removeSongFromPlaylist(song, playlist!).whenComplete(() =>
                    ScaffoldMessenger.of(Get.context!)
                        .showSnackBar(snackbar(Get.context!, 'Removed from ${playlist!.title}')));
              },
            )
          else
            const SizedBox.shrink(),
          if (calledFromQueue)
            ListTile(
                visualDensity: const VisualDensity(vertical: -1),
                leading: Icons.delete_rounded.icon.mk,
                title: 'removeFromQueue'.tr.text.mk,
                onTap: () {
                  Navigator.of(context).pop();
                  if (playerController.currentSong.value!.id == song.id) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(snackbar(context, 'songRemovedfromQueueCurrSong'.tr, size: SanckBarSize.BIG));
                  } else {
                    playerController.removeFromQueue(song);
                    ScaffoldMessenger.of(context).showSnackBar(snackbar(context, 'songRemovedfromQueue'.tr));
                  }
                })
          else
            const SizedBox.shrink(),
          Obx(
            () => (songInfoController.isDownloaded.isTrue &&
                    (playlist?.playlistId != 'SongDownloads' && playlist?.playlistId != 'SongsCache'))
                ? ListTile(
                    contentPadding: const EdgeInsets.only(left: 15),
                    visualDensity: const VisualDensity(vertical: -1),
                    leading: Icons.delete.icon.mk,
                    title: 'deleteDownloadData'.tr.text.mk,
                    onTap: () {
                      Navigator.of(context).pop();
                      final box = Hive.box('SongDownloads');
                      Get.find<LibrarySongsController>()
                          .removeSong(song, true, url: box.get(song.id)['url'])
                          .then((value) async {
                        box.delete(song.id).then((value) {
                          if (playlist != null) {
                            Get.find<PlayListNAlbumScreenController>(tag: Key(playlist!.playlistId).hashCode.toString())
                                .checkDownloadStatus();
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                snackbar(context, 'deleteDownloadedDataAlert'.tr, size: SanckBarSize.BIG));
                          }
                        });
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
          ListTile(
            leading: Icons.open_with.icon.mk,
            title: 'openIn'.tr.text.mk,
            trailing: sizedBox.w360.child(
              row.spaceEvenly.children([
                IconButton(
                  splashRadius: 10,
                  onPressed: () {
                    launchUrl(Uri.parse('https://youtube.com/watch?v=${song.id}'));
                  },
                  icon: Ionicons.logo_youtube.icon.mk,
                ),
                IconButton(
                  splashRadius: 10,
                  onPressed: () {
                    launchUrl(Uri.parse('https://music.youtube.com/watch?v=${song.id}'));
                  },
                  icon: Ionicons.play_circle.icon.mk,
                )
              ]),
            ),
            // trailing: SizedBox(
          ),
          if (calledFromPlayer)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 15),
              visualDensity: const VisualDensity(vertical: -1),
              leading: Icons.timer.icon.mk,
              title: 'sleepTimer'.tr.text.mk,
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  constraints: const BoxConstraints(maxWidth: 500),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  isScrollControlled: true,
                  context: playerController.homeScaffoldKey.currentState!.context,
                  barrierColor: Colors.transparent.withAlpha(100),
                  builder: (context) => const SleepTimerBottomSheet(),
                );
              },
            ),
          ListTile(
            contentPadding: const EdgeInsets.only(left: 15),
            visualDensity: const VisualDensity(vertical: -1),
            leading: Icons.share_rounded.icon.mk,
            title: 'shareSong'.tr.text.mk,
            onTap: () => Share.share('https://youtube.com/watch?v=${song.id}'),
          ),
        ]),
      ),
    );
  }

  List<Widget> artistWidgetList(MediaItem song, BuildContext context) {
    final artistList = [];
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey('id') && each['id'] != null) artistList.add(each);
      }
    }
    return artistList.isNotEmpty
        ? artistList
            .map((e) => ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (calledFromPlayer) {
                      Get.find<PlayerController>().playerPanelController.close();
                    }
                    if (calledFromQueue) {
                      final playerController = Get.find<PlayerController>();
                      playerController.playerPanelController.close();
                    }
                    await Get.toNamed(ScreenNavigationSetup.artistScreen,
                        id: ScreenNavigationSetup.id, arguments: [true, e['id']]);
                  },
                  tileColor: Colors.transparent,
                  leading: Icons.person_rounded.icon.mk,
                  title: Text("${"viewArtist".tr} (${e['name']})"),
                ))
            .toList()
        : [const SizedBox.shrink()];
  }
}

class SongInfoController extends GetxController with RemoveSongFromPlaylistMixin {
  final isCurrentSongFav = false.obs;
  final MediaItem song;
  final bool calledFromPlayer;
  List artistList = [].obs;
  final isDownloaded = false.obs;

  SongInfoController(this.song, this.calledFromPlayer) {
    _setInitStatus(song);
  }

  _setInitStatus(MediaItem song) async {
    isDownloaded.value = Hive.box('SongDownloads').containsKey(song.id);
    isCurrentSongFav.value = (await Hive.openBox('LIBFAV')).containsKey(song.id);
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey('id') && each['id'] != null) artistList.add(each);
      }
    }
  }

  void setDownloadStatus(bool isDownloaded_) {
    if (isDownloaded_) {
      Future.delayed(const Duration(milliseconds: 100), () => isDownloaded.value = isDownloaded_);
    }
  }

  Future<void> toggleFav() async {
    if (calledFromPlayer) {
      final cntrl = Get.find<PlayerController>();
      if (cntrl.currentSong.value == song) {
        cntrl.toggleFavourite();
        isCurrentSongFav.value = !isCurrentSongFav.value;
        return;
      }
    }
    final box = await Hive.openBox('LIBFAV');
    isCurrentSongFav.isFalse ? box.put(song.id, MediaItemBuilder.toJson(song)) : box.delete(song.id);
    isCurrentSongFav.value = !isCurrentSongFav.value;
  }
}

mixin RemoveSongFromPlaylistMixin {
  Future<void> removeSongFromPlaylist(MediaItem item, Playlist playlist) async {
    final box = await Hive.openBox(playlist.playlistId);
    //Library songs case
    if (playlist.playlistId == 'SongsCache') {
      if (!box.containsKey(item.id)) {
        Hive.box('SongDownloads').delete(item.id);
        Get.find<LibrarySongsController>().removeSong(item, true);
      } else {
        Get.find<LibrarySongsController>().removeSong(item, false);
        box.delete(item.id);
      }
    } else if (playlist.playlistId == 'SongDownloads') {
      box.delete(item.id);
      Get.find<LibrarySongsController>().removeSong(item, true);
    } else if (!playlist.isPipedPlaylist) {
      //Other playlist song case
      final index = box.values.toList().indexWhere((ele) => ele['videoId'] == item.id);
      await box.deleteAt(index);
    }

    // this try catch block is to handle the case when song is removed from libsongs sections
    try {
      final plstCntroller = Get.find<PlayListNAlbumScreenController>(tag: Key(playlist.playlistId).hashCode.toString());
      if (playlist.isPipedPlaylist) {
        final res = await Get.find<PipedServices>().getPlaylistSongs(playlist.playlistId);
        final songIndex = res.indexWhere((element) => element.id == item.id);
        if (songIndex != -1) {
          final res = await Get.find<PipedServices>().removeFromPlaylist(playlist.playlistId, songIndex);
          if (res.code == 1) {
            plstCntroller.addNRemoveItemsinList(item, action: 'remove');
          }
        }
        return;
      }

      try {
        plstCntroller.addNRemoveItemsinList(item, action: 'remove');
        // ignore: empty_catches
      } catch (e) {}
    } catch (e) {
      printERROR('Some Error in removeSongFromPlaylist (might irrelevant): $e');
    }

    if (playlist.playlistId == 'SongDownloads' || playlist.playlistId == 'SongsCache') return;
    box.close();
  }
}
