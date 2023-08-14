import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/piped_service.dart';
import '/ui/utils/home_library_controller.dart';
import '/ui/widgets/snackbar.dart';
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
    librPlstCntrller.changeCreationMode("local");
    librPlstCntrller.textInputController.text ="";
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        height: (isPipedLinked && !renamePlaylist) ? 215 : 170,
        padding:
            const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
        child: Stack(
          children: [
            Column(children: [
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
              if (isPipedLinked && !renamePlaylist)
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio(
                              value: "piped",
                              groupValue:
                                  librPlstCntrller.playlistCreationMode.value,
                              onChanged: librPlstCntrller.changeCreationMode),
                          const Text("Piped"),
                        ],
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Row(
                        children: [
                          Radio(
                              value: "local",
                              groupValue:
                                  librPlstCntrller.playlistCreationMode.value,
                              onChanged: librPlstCntrller.changeCreationMode),
                          const Text("Local"),
                        ],
                      )
                    ],
                  ),
                ),
              TextField(
                  textCapitalization: TextCapitalization.sentences,
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
                            style:
                                TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        ),
                        onTap: () async {
                          if (renamePlaylist) {
                            librPlstCntrller
                                .renamePlaylist(playlist!)
                                .then((value) {
                              if (value) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context, "Renamed successfully!",
                                        size: SanckBarSize.MEDIUM));
                              }
                            });
                          } else {
                            librPlstCntrller
                                .createNewPlaylist(
                                    createPlaylistNaddSong: isCreateNadd,
                                    songItem: songItem)
                                .then((value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(
                                        context,
                                        isCreateNadd
                                            ? "Playlist created & Song added"
                                            : "Playlist created",
                                        size: SanckBarSize.MEDIUM));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context, "Some error occured!",
                                        size: SanckBarSize.MEDIUM));
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
            Obx(() =>
                (librPlstCntrller.creationInProgress.isTrue && isPipedLinked)
                    ? const Positioned(
                        top: 5,
                        right: 8,
                        child: SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.transparent,
                              strokeWidth: 2,
                            )),
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
