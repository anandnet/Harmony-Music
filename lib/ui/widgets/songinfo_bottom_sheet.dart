import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/utils/home_library_controller.dart';
import 'package:harmonymusic/ui/widgets/add_to_playlist.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

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
          leading: SizedBox.square(
              dimension: 50,
              child: ImageWidget(
                song: song,
              )),
          title: Text(
            song.title,
            maxLines: 1,
          ),
          subtitle: Text(song.artist!),
          trailing: IconButton(
              onPressed: songInfoController.toggleFav,
              icon: Obx(() => Icon(
                    songInfoController.isCurrentSongFav.isFalse
                        ? Icons.favorite_border
                        : Icons.favorite,
                    color: Theme.of(context).textTheme.titleMedium!.color,
                  ))),
        ),
        const Divider(),
        ListTile(
          visualDensity: const VisualDensity(vertical: -1),
          leading: const Icon(Icons.playlist_add),
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
                leading: const Icon(Icons.merge),
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
                leading: const Icon(Icons.album),
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
                !(playlist!.playlistId == "LIBCAC") &&
                !(playlist!.playlistId == "LIBRP"))
            ? ListTile(
                visualDensity: const VisualDensity(vertical: -1),
                leading: const Icon(Icons.delete_rounded),
                title: const Text("Remove form playlist"),
                onTap: () {
                  Navigator.of(context).pop();
                  songInfoController
                      .removeSongFromPlaylist(song, playlist!)
                      .whenComplete(() => ScaffoldMessenger.of(context)
                          .showSnackBar(snackbar(
                              context, "Removed from ${playlist!.title}",
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
        ListTile(
          contentPadding: const EdgeInsets.only(bottom: 20, left: 15),
          visualDensity: const VisualDensity(vertical: -1),
          leading: const Icon(Icons.share),
          title: const Text("Share this song"),
          onTap: () => Share.share("https://youtube.com/watch?v=${song.id}"),
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
                    Get.toNamed(ScreenNavigationSetup.artistScreen,
                        id: ScreenNavigationSetup.id,
                        arguments: [true, e['id']]);
                    //
                  },
                  tileColor: Colors.transparent,
                  leading: const Icon(Icons.person),
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
    final box = await Hive.openBox(playlist.playlistId);
    box.delete(item.id);
    try {
      final plstCntroller = Get.find<PlayListNAlbumScreenController>();
      plstCntroller.addNRemoveItemsinList(item, action: 'remove');
      // ignore: empty_catches
    } catch (e) {}
    //Updating Library song list in frontend
    if (playlist.playlistId == "SongsCache") {
      Get.find<LibrarySongsController>().cachedSongsList.remove(item);
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
