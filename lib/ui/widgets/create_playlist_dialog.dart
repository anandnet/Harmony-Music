import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/utils/home_library_controller.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';

import '../../models/playlist.dart';

class CreateNRenamePlaylistPopup extends StatelessWidget {
  const CreateNRenamePlaylistPopup(
      {super.key,
      this.isCreateNadd = false,
      this.songItem,
      this.renamePlaylist = false,
      this.playlist});
  final bool isCreateNadd;
  final bool renamePlaylist;
  final MediaItem? songItem;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    final librPlstCntrller = Get.find<LibraryPlaylistsController>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: 170,
        padding:
            const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                renamePlaylist ? "Rename Playlist" : "Create New Playlist",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          TextField(
              autofocus: true,
              cursorColor: Theme.of(context).textTheme.titleSmall!.color,
              controller: librPlstCntrller.textInputController),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("Cancel"),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                      borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: Text(
                        isCreateNadd
                            ? "Create & add"
                            : renamePlaylist
                                ? "Rename"
                                : "Create",
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      ),
                    ),
                    onTap: () async {
                      if (renamePlaylist) {
                        librPlstCntrller
                            .renamePlaylist(playlist!)
                            .then((value) {
                          if (value) {
                            Navigator.of(context).pop();
                             ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "Renamed successfully!", 200));
                          }
                        });
                      } else {
                        librPlstCntrller
                            .createNewPlaylist(
                                createPlaylistNaddSong: isCreateNadd,
                                songItem: songItem)
                            .then((value) {
                          if (value) {
                            ScaffoldMessenger.of(context).showSnackBar(snackbar(
                                context, "Playlist created & Song added", 200));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                snackbar(context, "Some error occured!", 150));
                          }
                          Navigator.of(context).pop();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
