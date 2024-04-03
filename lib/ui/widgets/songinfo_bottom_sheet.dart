import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/services/piped_service.dart';
import '/ui/widgets/sleep_timer_bottom_sheet.dart';
import '/ui/player/player_controller.dart';
import '../screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import '../screens/Library/library_controller.dart';
import '/ui/widgets/add_to_playlist.dart';
import '/ui/widgets/snackbar.dart';
import '../../models/media_Item_builder.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
import 'song_download_btn.dart';
import 'image_widget.dart';

class SongInfoBottomSheet extends StatelessWidget {
  const SongInfoBottomSheet(this.song,
      {super.key,
      this.playlist,
      this.calledFromPlayer = false,
      this.calledFromQueue = false});
  final MediaItem song;
  final Playlist? playlist;
  final bool calledFromPlayer;
  final bool calledFromQueue;

  @override
  Widget build(BuildContext context) {
    final songInfoController =
        Get.put(SongInfoController(song, calledFromPlayer));
    return Padding(
      padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.only(left: 15, top: 7, right: 10, bottom: 0),
            leading: ImageWidget(
              song: song,
              size: 50,
            ),
            title: Text(
              song.title,
              maxLines: 1,
            ),
            subtitle: Text(song.artist!),
            trailing: SizedBox(
              width: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  calledFromPlayer
                      ? IconButton(
                          onPressed: () => Share.share(
                              "https://youtube.com/watch?v=${song.id}"),
                          icon: Icon(
                            Icons.share_rounded,
                            color:
                                Theme.of(context).textTheme.titleMedium!.color,
                          ))
                      : IconButton(
                          onPressed: songInfoController.toggleFav,
                          icon: Obx(() => Icon(
                                songInfoController.isCurrentSongFav.isFalse
                                    ? Icons.favorite_border_rounded
                                    : Icons.favorite_rounded,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .color,
                              ))),
                  SongDownloadButton(
                    song_: song,
                    isDownloadingDoneCallback:
                        songInfoController.setDownloadStatus,
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          ListTile(
            visualDensity: const VisualDensity(vertical: -1),
            leading: const Icon(Icons.sensors_rounded),
            title: Text("startRadio".tr),
            onTap: () {
              Navigator.of(context).pop();
              Get.find<PlayerController>().startRadio(song);
            },
          ),
          (calledFromPlayer || calledFromQueue)
              ? const SizedBox.shrink()
              : ListTile(
                  visualDensity: const VisualDensity(vertical: -1),
                  leading: const Icon(Icons.playlist_play_rounded),
                  title: Text("playNext".tr),
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.find<PlayerController>().playNext(song);
                  },
                ),
          ListTile(
            visualDensity: const VisualDensity(vertical: -1),
            leading: const Icon(Icons.playlist_add_rounded),
            title: Text("addToPlaylist".tr),
            onTap: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AddToPlaylist([song]),
              ).whenComplete(() => Get.delete<AddToPlaylistController>());
            },
          ),
          (calledFromPlayer || calledFromQueue)
              ? const SizedBox.shrink()
              : ListTile(
                  visualDensity: const VisualDensity(vertical: -1),
                  leading: const Icon(Icons.merge_rounded),
                  title: Text("enqueueSong".tr),
                  onTap: () {
                    Get.find<PlayerController>().enqueueSong(song).whenComplete(
                        () => ScaffoldMessenger.of(context).showSnackBar(
                            snackbar(context, "songEnqueueAlert".tr,
                                size: SanckBarSize.MEDIUM)));
                    Navigator.of(context).pop();
                  },
                ),
          song.extras!['album'] != null
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: -1),
                  leading: const Icon(Icons.album_rounded),
                  title: Text("goToAlbum".tr),
                  onTap: () {
                    Navigator.of(context).pop();
                    if (calledFromPlayer) {
                      Get.find<PlayerController>()
                          .playerPanelController
                          .close();
                    }
                    if (calledFromQueue) {
                      final playerController = Get.find<PlayerController>();
                      playerController.playerPanelController.close();
                    }
                    Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                        id: ScreenNavigationSetup.id,
                        arguments: [true, song.extras!['album']['id'], true]);
                  },
                )
              : const SizedBox.shrink(),
          ...artistWidgetList(song, context),
          (playlist != null &&
                      !playlist!.isCloudPlaylist &&
                      !(playlist!.playlistId == "LIBRP")) ||
                  (playlist != null && playlist!.isPipedPlaylist)
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: -1),
                  leading: const Icon(Icons.delete_rounded),
                  title: playlist!.title == "Library Songs"
                      ? Text("removeFromLib".tr)
                      : Text("removeFromPlaylist".tr),
                  onTap: () {
                    Navigator.of(context).pop();
                    songInfoController
                        .removeSongFromPlaylist(song, playlist!)
                        .whenComplete(() => ScaffoldMessenger.of(Get.context!)
                            .showSnackBar(snackbar(
                                Get.context!, "Removed from ${playlist!.title}",
                                size: SanckBarSize.MEDIUM)));
                  },
                )
              : const SizedBox.shrink(),
          (calledFromQueue)
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: -1),
                  leading: const Icon(Icons.delete_rounded),
                  title: Text("removeFromQueue".tr),
                  onTap: () {
                    Navigator.of(context).pop();
                    final plarcntr = Get.find<PlayerController>();
                    if (plarcntr.currentSong.value!.id == song.id) {
                      ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context, "songRemovedfromQueueCurrSong".tr,
                          size: SanckBarSize.BIG));
                    } else {
                      Get.find<PlayerController>().removeFromQueue(song);
                      ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context, "songRemovedfromQueue".tr,
                          size: SanckBarSize.MEDIUM));
                    }
                  })
              : const SizedBox.shrink(),
          Obx(
            () => (songInfoController.isDownloaded.isTrue &&
                    (playlist?.playlistId != "SongDownloads" &&
                        playlist?.playlistId != "SongsCache"))
                ? ListTile(
                    contentPadding: const EdgeInsets.only(left: 15),
                    visualDensity: const VisualDensity(vertical: -1),
                    leading: const Icon(Icons.delete),
                    title: Text("deleteDownloadData".tr),
                    onTap: () {
                      Navigator.of(context).pop();
                      final box = Hive.box("SongDownloads");
                      Get.find<LibrarySongsController>()
                          .removeSong(song, true, url: box.get(song.id)['url'])
                          .then((value) async {
                        box.delete(song.id).then((value) {
                          if (playlist != null) {
                            Get.find<PlayListNAlbumScreenController>(
                                    tag: Key(playlist!.playlistId)
                                        .hashCode
                                        .toString())
                                .checkDownloadStatus();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(snackbar(
                              context, "deleteDownloadedDataAlert".tr,
                              size: SanckBarSize.BIG));
                        });
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
          ListTile(
            leading: const Icon(Icons.open_with),
            title: Text("openIn".tr),
            trailing: SizedBox(
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    splashRadius: 10,
                    onPressed: () {
                      launchUrl(
                          Uri.parse("https://youtube.com/watch?v=${song.id}"));
                    },
                    icon: const Icon(Ionicons.logo_youtube),
                  ),
                  IconButton(
                    splashRadius: 10,
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://music.youtube.com/watch?v=${song.id}"));
                    },
                    icon: const Icon(Ionicons.play_circle),
                  )
                ],
              ),
            ),
          ),
          if (!calledFromPlayer)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 15),
              visualDensity: const VisualDensity(vertical: -1),
              leading: const Icon(Icons.share_rounded),
              title: Text("shareSong".tr),
              onTap: () =>
                  Share.share("https://youtube.com/watch?v=${song.id}"),
            ),
          if (calledFromPlayer)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 15),
              visualDensity: const VisualDensity(vertical: -1),
              leading: const Icon(Icons.timer),
              title: Text("sleepTimer".tr),
              onTap: () {
                Navigator.of(context).pop();
                final playerController = Get.find<PlayerController>();
                showModalBottomSheet(
                  constraints: const BoxConstraints(maxWidth: 500),
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10.0)),
                  ),
                  isScrollControlled: true,
                  context:
                      playerController.homeScaffoldkey.currentState!.context,
                  barrierColor: Colors.transparent.withAlpha(100),
                  builder: (context) => const SleepTimerBottomSheet(),
                );
              },
            ),
        ],
      ),
    );
  }

  List<Widget> artistWidgetList(MediaItem song, BuildContext context) {
    final artistList = [];
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey("id") && each['id'] != null) artistList.add(each);
      }
    }
    return artistList.isNotEmpty
        ? artistList
            .map((e) => ListTile(
                  onTap: () async {
                    Navigator.of(context).pop();
                    if (calledFromPlayer) {
                      Get.find<PlayerController>()
                          .playerPanelController
                          .close();
                    }
                    if (calledFromQueue) {
                      final playerController = Get.find<PlayerController>();
                      playerController.playerPanelController.close();
                    }
                    await Get.toNamed(ScreenNavigationSetup.artistScreen,
                        id: ScreenNavigationSetup.id,
                        preventDuplicates: true,
                        arguments: [true, e['id']]);
                  },
                  tileColor: Colors.transparent,
                  leading: const Icon(Icons.person_rounded),
                  title: Text("${"viewArtist".tr} (${e['name']})"),
                ))
            .toList()
        : [const SizedBox.shrink()];
  }
}

class SongInfoController extends GetxController {
  final isCurrentSongFav = false.obs;
  final MediaItem song;
  final bool calledFromPlayer;
  List artistList = [].obs;
  final isDownloaded = false.obs;
  SongInfoController(this.song, this.calledFromPlayer) {
    _setInitStatus(song);
  }
  _setInitStatus(MediaItem song) async {
    isDownloaded.value = Hive.box("SongDownloads").containsKey(song.id);
    isCurrentSongFav.value =
        (await Hive.openBox("LIBFAV")).containsKey(song.id);
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey("id") && each['id'] != null) artistList.add(each);
      }
    }
  }

  void setDownloadStatus(bool isDownloaded_) {
    if (isDownloaded_) {
      Future.delayed(const Duration(milliseconds: 100),
          () => isDownloaded.value = isDownloaded_);
    }
  }

  Future<void> removeSongFromPlaylist(MediaItem item, Playlist playlist) async {
    final box = await Hive.openBox(playlist.playlistId);
    //Library songs case
    if (playlist.playlistId == "SongsCache") {
      if (!box.containsKey(item.id)) {
        Hive.box("SongDownloads").delete(item.id);
        Get.find<LibrarySongsController>().removeSong(item, true);
      } else {
        Get.find<LibrarySongsController>().removeSong(item, false);
        box.delete(item.id);
      }
    } else if (playlist.playlistId == "SongDownloads") {
      box.delete(item.id);
      Get.find<LibrarySongsController>().removeSong(item, true);
    } else if (!playlist.isPipedPlaylist) {
      //Other playlist song case
      final index =
          box.values.toList().indexWhere((ele) => ele['videoId'] == item.id);
      await box.deleteAt(index);
    }

    final plstCntroller = Get.find<PlayListNAlbumScreenController>(
        tag: Key(playlist.playlistId).hashCode.toString());
    if (playlist.isPipedPlaylist) {
      final res =
          await Get.find<PipedServices>().getPlaylistSongs(playlist.playlistId);
      final songIndex = res.indexWhere((element) => element.id == item.id);
      if (songIndex != -1) {
        final res = await Get.find<PipedServices>()
            .removeFromPlaylist(playlist.playlistId, songIndex);
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

    if (playlist.playlistId == "SongDownloads" ||
        playlist.playlistId == "SongsCache") return;
    box.close();
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
    final box = await Hive.openBox("LIBFAV");
    isCurrentSongFav.isFalse
        ? box.put(song.id, MediaItemBuilder.toJson(song))
        : box.delete(song.id);
    isCurrentSongFav.value = !isCurrentSongFav.value;
  }
}
