import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '/services/piped_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/screens/playlistnalbum_screen_controller.dart';
import '/ui/utils/home_library_controller.dart';
import '/ui/widgets/add_to_playlist.dart';
import '/ui/widgets/snackbar.dart';
import '../../models/media_Item_builder.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
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
    return Column(
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
          trailing: calledFromPlayer
              ? IconButton(
                  onPressed: () =>
                      Share.share("https://youtube.com/watch?v=${song.id}"),
                  icon: Icon(
                    Icons.share_rounded,
                    color: Theme.of(context).textTheme.titleMedium!.color,
                  ))
              : IconButton(
                  onPressed: songInfoController.toggleFav,
                  icon: Obx(() => Icon(
                        songInfoController.isCurrentSongFav.isFalse
                            ? Icons.favorite_border_rounded
                            : Icons.favorite_rounded,
                        color: Theme.of(context).textTheme.titleMedium!.color,
                      ))),
        ),
        const Divider(),
        ListTile(
          visualDensity: const VisualDensity(vertical: -1),
          leading: const Icon(Icons.sensors_rounded),
          title: const Text("Start Radio"),
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
                title: const Text("Play next"),
                onTap: () {
                  Navigator.of(context).pop();
                  Get.find<PlayerController>().playNext(song);
                },
              ),
        ListTile(
          visualDensity: const VisualDensity(vertical: -1),
          leading: const Icon(Icons.playlist_add_rounded),
          title: const Text("Add to playlist"),
          onTap: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => AddToPlaylist(song),
            ).whenComplete(() => Get.delete<AddToPlaylistController>());
          },
        ),
        (calledFromPlayer || calledFromQueue)
            ? const SizedBox.shrink()
            : ListTile(
                visualDensity: const VisualDensity(vertical: -1),
                leading: const Icon(Icons.merge_rounded),
                title: const Text("Enqueue this song"),
                onTap: () {
                  Get.find<PlayerController>().enqueueSong(song).whenComplete(
                      () => ScaffoldMessenger.of(context).showSnackBar(snackbar(
                          context, "Song enqueued!",
                          size: SanckBarSize.MEDIUM)));
                  Navigator.of(context).pop();
                },
              ),
        song.extras!['album'] != null
            ? ListTile(
                visualDensity: const VisualDensity(vertical: -1),
                leading: const Icon(Icons.album_rounded),
                title: const Text("Go to album"),
                onTap: () {
                  Navigator.of(context).pop();
                  if (calledFromPlayer) {
                    Get.find<PlayerController>().playerPanelController.close();
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
                title: playlist!.playlistId == "SongsCache"
                    ? const Text("Remove from cache")
                    : const Text("Remove from playlist"),
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
                title: const Text("Remove form Queue"),
                onTap: () {
                  Navigator.of(context).pop();
                  final plarcntr = Get.find<PlayerController>();
                  if (plarcntr.currentSong.value!.id == song.id) {
                    ScaffoldMessenger.of(context).showSnackBar(snackbar(
                        context, "You can't remove currently playing song",
                        size: SanckBarSize.BIG));
                  } else {
                    Get.find<PlayerController>().removeFromQueue(song);
                    ScaffoldMessenger.of(context).showSnackBar(snackbar(
                        context, "Removed from queue !",
                        size: SanckBarSize.MEDIUM));
                  }
                })
            : const SizedBox.shrink(),
        calledFromPlayer
            ? const SizedBox(
                height: 10,
              )
            : ListTile(
                contentPadding: const EdgeInsets.only(bottom: 20, left: 15),
                visualDensity: const VisualDensity(vertical: -1),
                leading: const Icon(Icons.share_rounded),
                title: const Text("Share this song"),
                onTap: () =>
                    Share.share("https://youtube.com/watch?v=${song.id}"),
              ),
      ],
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
                  title: Text("View Artist (${e['name']})"),
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
  SongInfoController(this.song, this.calledFromPlayer) {
    _setInitStatus(song);
  }
  _setInitStatus(MediaItem song) async {
    isCurrentSongFav.value =
        (await Hive.openBox("LIBFAV")).containsKey(song.id);
    final artists = song.extras!['artists'];
    if (artists != null) {
      for (dynamic each in artists) {
        if (each.containsKey("id") && each['id'] != null) artistList.add(each);
      }
    }
  }

  Future<void> removeSongFromPlaylist(MediaItem item, Playlist playlist) async {
    final plstCntroller = Get.find<PlayListNAlbumScreenController>();
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

    final box = await Hive.openBox(playlist.playlistId);
    box.delete(item.id);
    try {
      plstCntroller.addNRemoveItemsinList(item, action: 'remove');
      // ignore: empty_catches
    } catch (e) {}
    //Updating Library song list in frontend
    if (playlist.playlistId == "SongsCache") {
      Get.find<LibrarySongsController>().removeSong(item);
      return;
    }
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
