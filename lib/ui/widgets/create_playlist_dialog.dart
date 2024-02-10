import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/services/piped_service.dart';
import '../screens/Library/library_controller.dart';
import '/ui/widgets/snackbar.dart';
import '../../models/playlist.dart';
import 'common_dialog_widget.dart';

class CreateNRenamePlaylistPopup extends StatelessWidget {
  const CreateNRenamePlaylistPopup(
      {super.key,
      this.isCreateNadd = false,
      this.songItems,
      this.renamePlaylist = false,
      this.playlist});
  final bool isCreateNadd;
  final bool renamePlaylist;
  final List<MediaItem>? songItems;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    final librPlstCntrller = Get.find<LibraryPlaylistsController>();
    librPlstCntrller.changeCreationMode("local");
    librPlstCntrller.textInputController.text = "";
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    return CommonDialog(
      child: Container(
        height: (isPipedLinked && !renamePlaylist) ? 245 : 200,
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
                    renamePlaylist
                        ? "renamePlaylist".tr
                        : "CreateNewPlaylist".tr,
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
                          Text("Piped".tr),
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
                          Text("local".tr),
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("cancel".tr),
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
                                ? "createnAdd".tr
                                : renamePlaylist
                                    ? "rename".tr
                                    : "create".tr,
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
                                    snackbar(context, "playlistRenameAlert".tr,
                                        size: SanckBarSize.MEDIUM));
                              }
                            });
                          } else {
                            librPlstCntrller
                                .createNewPlaylist(
                                    createPlaylistNaddSong: isCreateNadd,
                                    songItems: songItems)
                                .then((value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(
                                        context,
                                        isCreateNadd
                                            ? "playlistCreatednsongAddedAlert"
                                                .tr
                                            : "playlistCreatedAlert".tr,
                                        size: SanckBarSize.MEDIUM));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    snackbar(context, "errorOccuredAlert".tr,
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
