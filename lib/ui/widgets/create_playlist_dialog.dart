import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/services/piped_service.dart';
import 'package:harmonymusic/ui/screens/Library/library_controller.dart';
import 'package:harmonymusic/ui/widgets/common_dialog_widget.dart';
import 'package:harmonymusic/ui/widgets/modified_text_field.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';

class CreateNRenamePlaylistPopup extends StatelessWidget {
  const CreateNRenamePlaylistPopup({
    super.key,
    this.isCreateNadd = false,
    this.songItems,
    this.renamePlaylist = false,
    this.playlist,
  });

  final bool isCreateNadd;
  final bool renamePlaylist;
  final List<MediaItem>? songItems;
  final Playlist? playlist;

  @override
  Widget build(BuildContext context) {
    final libPlaylistCtrl = Get.find<LibraryPlaylistsController>();
    libPlaylistCtrl.changeCreationMode('local');
    libPlaylistCtrl.textInputController.text = '';
    final isPipedLinked = Get.find<PipedServices>().isLoggedIn;
    return CommonDialog(
      child: Container(
        height: (isPipedLinked && !renamePlaylist) ? 245 : 200,
        padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 10),
        child: Stack(
          children: [
            column.children([
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    renamePlaylist ? 'renamePlaylist'.tr : 'CreateNewPlaylist'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              if (isPipedLinked && !renamePlaylist)
                Obx(() => row.children([
                      row.children([
                        Radio(
                            value: 'piped',
                            groupValue: libPlaylistCtrl.playlistCreationMode.value,
                            onChanged: libPlaylistCtrl.changeCreationMode),
                        'Piped'.tr.text.mk,
                      ]),
                      const SizedBox(width: 15),
                      row.children([
                        Radio(
                            value: 'local',
                            groupValue: libPlaylistCtrl.playlistCreationMode.value,
                            onChanged: libPlaylistCtrl.changeCreationMode),
                        'local'.tr.text.mk,
                      ]),
                    ])),
              ModifiedTextField(
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                cursorColor: Theme.of(context).textTheme.titleSmall!.color,
                controller: libPlaylistCtrl.textInputController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 5),
                  focusColor: Colors.white,
                ),
              ),
              padding.pt44.child(
                row.spaceAround.children([
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: padding.p10.child('cancel'.tr.text.mk),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.titleLarge!.color, borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      child: padding.ph30.pv20.child(
                        Text(
                          isCreateNadd
                              ? 'createnAdd'.tr
                              : renamePlaylist
                                  ? 'rename'.tr
                                  : 'create'.tr,
                          style: TextStyle(color: Theme.of(context).canvasColor),
                        ),
                      ),
                      onTap: () async {
                        if (renamePlaylist) {
                          libPlaylistCtrl.renamePlaylist(playlist!).then((value) {
                            if (value) {
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(snackbar(context, 'playlistRenameAlert'.tr));
                            }
                          });
                        } else {
                          libPlaylistCtrl
                              .createNewPlaylist(createPlaylistNaddSong: isCreateNadd, songItems: songItems)
                              .then((value) {
                            if (!context.mounted) return;
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(snackbar(context,
                                  isCreateNadd ? 'playlistCreatednsongAddedAlert'.tr : 'playlistCreatedAlert'.tr));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(snackbar(context, 'errorOccuredAlert'.tr));
                            }
                            Navigator.of(context).pop();
                          });
                        }
                      },
                    ),
                  ),
                ]),
              )
            ]),
            Obx(() => (libPlaylistCtrl.creationInProgress.isTrue && isPipedLinked)
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
