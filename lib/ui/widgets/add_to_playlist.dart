import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/ui/widgets/create_playlist_dialog.dart';
import 'package:hive/hive.dart';

import '../../models/playlist.dart';
import 'snackbar.dart';

class AddToPlaylist extends StatelessWidget {
  const AddToPlaylist(this.songItem, {super.key});
  final MediaItem songItem;

  @override
  Widget build(BuildContext context) {
    final addToPlaylistController = Get.put(AddToPlaylistController());
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 350,
        padding:
            const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10.0, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Create playlist",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                InkWell(
                  child: const Icon(Icons.playlist_add_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) => CreateNRenamePlaylistPopup(
                          isCreateNadd: true, songItem: songItem),
                    );
                  },
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: BorderRadius.circular(10)),
            height: 250,
            //color: Colors.green,
            child: Obx(
              () =>addToPlaylistController.playlists.isNotEmpty? ListView.builder(
                itemCount: addToPlaylistController.playlists.length,
                itemBuilder: (context, index) => ListTile(
                  leading: const Icon(Icons.playlist_play_rounded),
                  title: Text(
                    (addToPlaylistController.playlists[index]).title,
                  ),
                  onTap: () {
                    addToPlaylistController
                        .addSongToPlaylist(
                            songItem,
                            (addToPlaylistController.playlists[index])
                                .playlistId,
                            context)
                        .then((value) {
                      if (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            snackbar(context, "Song added to playlist!", 180));
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            snackbar(context, "Song already exists!", 160));
                        Navigator.of(context).pop();
                      }
                    });
                  },
                ),
              ):const Center(child: Text("You don't have lib playlists!"),),
            ),
          )
        ]),
      ),
    );
  }
}

class AddToPlaylistController extends GetxController {
  final RxList<Playlist> playlists = RxList();
  AddToPlaylistController() {
    _getAllPlaylist();
  }

  Future<void> _getAllPlaylist() async {
    final plstsBox = await Hive.openBox("LibraryPlaylists");
    playlists.value = plstsBox.values
        .map((e) {
          if (!e["isCloudPlaylist"]) return Playlist.fromJson(e);
        })
        .whereType<Playlist>()
        .toList();
  }

  Future<bool> addSongToPlaylist(
      MediaItem song, String playlistId, BuildContext context) async {
    final plstBox = await Hive.openBox(playlistId);
    if (!plstBox.containsKey(song.id)) {
      plstBox.put(song.id, MediaItemBuilder.toJson(song));
      plstBox.close();
      return true;
    } else {
      plstBox.close();
      return false;
    }
  }
}
