import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';

import '../../services/permission_service.dart';
import 'common_dialog_widget.dart';

import 'package:path/path.dart' as p;

class RestoreDialog extends StatelessWidget {
  const RestoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final restoreDialogController = Get.put(RestoreDialogController());
    return CommonDialog(
      child: Container(
        height: 300,
        padding:
            const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                child: Text(
                  "restoreSettingsAndPlaylists".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 150,
                child: Center(
                  child: Obx(() => restoreDialogController.restoreProgress
                              .toInt() ==
                          restoreDialogController.filesToRestore.toInt()
                      ? Text("restoreMsg".tr)
                      : restoreDialogController.restoreRunning.isTrue
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "${restoreDialogController.restoreProgress.toInt()}/${restoreDialogController.filesToRestore.toInt()}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("restoring".tr)
                              ],
                            )
                          : const SizedBox()),
                ),
              ),
              SizedBox(
                width: double.maxFinite,
                child: Align(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.titleLarge!.color,
                        borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        if (restoreDialogController.restoreProgress.toInt() ==
                            restoreDialogController.filesToRestore.toInt()) {
                          exit(0);
                        } else {
                          restoreDialogController.backup();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Obx(
                          () => Text(
                            restoreDialogController.restoreProgress.toInt() ==
                                    restoreDialogController.filesToRestore
                                        .toInt()
                                ? "closeApp".tr
                                : "restore".tr,
                            style:
                                TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class RestoreDialogController extends GetxController {
  final restoreRunning = false.obs;
  final restoreProgress = (-1).obs;
  final filesToRestore = (0).obs;

  Future<void> backup() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    final FilePickerResult? pickedFileResult = await FilePicker.platform
        .pickFiles(
            dialogTitle: "Select backup file",
            type: FileType.custom,
            allowedExtensions: ['hmb'],
            allowMultiple: false);

    final String? pickedFile = pickedFileResult?.files.first.path;

    // is this check necessary?
    if (pickedFile == '/' || pickedFile == null) {
      return;
    }

    restoreProgress.value = 0;
    restoreRunning.value = true;
    final restoreFilePath = pickedFile.toString();
    final dbDirPath =
        p.join(Get.find<SettingsScreenController>().supportDirPath, "db");
    final Directory dbDir = Directory(dbDirPath);
    printInfo(info: dbDir.path);
    await Get.find<SettingsScreenController>().closeAllDatabases();
    await dbDir.delete(recursive: true);
    final bytes = await File(restoreFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    filesToRestore.value = archive.length;
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        final outputFile = File('$dbDirPath/$filename');
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(data);
        restoreProgress.value++;
      }
    }
    restoreRunning.value = false;
  }
}
