import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/ui/player/player_controller.dart';
import 'package:harmonymusic/ui/screens/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/add_to_playlist.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:hive/hive.dart';

import '../../models/media_Item_builder.dart';
import '../../models/playlist.dart';
import '../navigator.dart';
import 'image_widget.dart';

class SongInfoBottomSheet extends StatelessWidget {
  const SongInfoBottomSheet(this.song, {super.key, this.playlist});
  final MediaItem song;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    printINFO(playlist);
    final songInfoController = Get.put(SongInfoController(song));
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
        ListTile(
          visualDensity: const VisualDensity(vertical: -1),
          leading: const Icon(Icons.merge),
          title: const Text("Enqueue this song"),
          onTap: () {
            final playerCntrller = Get.find<PlayerController>();
            playerCntrller.currentQueue.isEmpty
                ? playerCntrller.pushSongToQueue(song)
                : playerCntrller.enqueueSong(song);
            Navigator.of(context).pop();
          },
        ),
        song.extras!['album'] != null
            ? ListTile(
                visualDensity: const VisualDensity(vertical: -1),
                leading: const Icon(Icons.album),
                title: const Text("Go to album"),
                onTap: (){
                  Navigator.of(context).pop();
                    Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
                      id: ScreenNavigationSetup.id, arguments: [true, song.extras!['album']['id'] ,true]);
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
                          .showSnackBar(snackbar(context,
                              "Removed from ${playlist!.title}", 200)));
                },
              )
            : const SizedBox.shrink(),
        const ListTile(
          contentPadding: EdgeInsets.only(bottom: 20, left: 15),
          visualDensity: VisualDensity(vertical: -1),
          leading: Icon(Icons.share),
          title: Text("Share this song"),
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
  List artistList = [].obs;
  SongInfoController(this.song) {
    final x = MediaItemBuilder.toJson(song).toString();
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
      printINFO(song.extras!['artists']);
    }
  }

  Future<void> removeSongFromPlaylist(MediaItem item, Playlist playlist) async {
    final box = await Hive.openBox(playlist.playlistId);
    box.delete(item.id);
    Get.find<PlayListNAlbumScreenController>()
        .addNRemoveItemsinList(item, action: 'remove');
    box.close();
  }

  Future<void> toggleFav() async {
    final box = await Hive.openBox("LIBFAV");
    isCurrentSongFav.isFalse
        ? box.put(song.id, MediaItemBuilder.toJson(song))
        : box.delete(song.id);
    isCurrentSongFav.value = !isCurrentSongFav.value;
  }
}
