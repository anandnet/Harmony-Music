import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';

import '/ui/screens/Settings/settings_screen_controller.dart';
import '/utils/helper.dart';
import '../../services/permission_service.dart';
import 'common_dialog_widget.dart';

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
                  "restoreAppData".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 150,
                child: Center(
                  child: Obx(() => restoreDialogController.restoreProgress
                              .toInt() ==
                          restoreDialogController.filesToRestore.toInt()
                      ? Text(
                          "restoreMsg".tr,
                          textAlign: TextAlign.center,
                        )
                      : restoreDialogController.processingFiles.isTrue
                          ? Text("processFiles".tr)
                          : restoreDialogController.restoreRunning.isTrue
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "${restoreDialogController.restoreProgress.toInt()}/${restoreDialogController.filesToRestore.toInt()}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text("restoring".tr)
                                  ],
                                )
                              : Text("letsStrart".tr)),
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
                          GetPlatform.isAndroid
                              ? Restart.restartApp()
                              : exit(0);
                        } else {
                          restoreDialogController.backup();
                        }
                      },
                      child: Obx(
                        () => Visibility(
                          visible: restoreDialogController
                                  .processingFiles.isFalse &&
                              restoreDialogController.restoreRunning.isFalse,
                          replacement: const SizedBox(
                            height: 40,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Obx(
                              () => Text(
                                restoreDialogController.restoreProgress
                                            .toInt() ==
                                        restoreDialogController.filesToRestore
                                            .toInt()
                                    ? "restartApp".tr
                                    : "restore".tr,
                                style: TextStyle(
                                    color: Theme.of(context).canvasColor),
                              ),
                            ),
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
  final processingFiles = false.obs;

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
            type: GetPlatform.isWindows ? FileType.custom : FileType.any,
            allowedExtensions: GetPlatform.isWindows ? ['hmb'] : null,
            allowMultiple: false);

    final String? pickedFile = pickedFileResult?.files.first.path;

    // is this check necessary?
    if (pickedFile == '/' || pickedFile == null) {
      return;
    }
    processingFiles.value = true;
    await Future.delayed(const Duration(seconds: 4));
    final restoreFilePath = pickedFile.toString();
    final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;
    final dbDirPath = await Get.find<SettingsScreenController>().dbDir;
    final Directory dbDir = Directory(dbDirPath);
    printInfo(info: dbDir.path);
    await Get.find<SettingsScreenController>().closeAllDatabases();

    //delele all the files with extension .hive
    for (final file in dbDir.listSync()) {
      if (file is File && file.path.endsWith('.hive')) {
        await file.delete();
      }
    }
    final bytes = await File(restoreFilePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    filesToRestore.value = archive.length;
    restoreProgress.value = 0;
    processingFiles.value = false;
    restoreRunning.value = true;
    for (final file in archive) {
      final filename = file.name;
      printINFO(filename);
      if (file.isFile) {
        final data = file.content as List<int>;
        final targetFileDir =
            filename.endsWith(".m4a") || filename.endsWith(".opus")
                ? "$supportDirPath/Music"
                : filename.endsWith(".png")
                    ? "$supportDirPath/thumbnails"
                    : dbDirPath;
        final outputFile = File('$targetFileDir/$filename');
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(data);
        restoreProgress.value++;
      }
    }
    // Clear file picker temp directory
    final tempFilePickerDirPath =
        "${(await getApplicationCacheDirectory()).path}/file_picker";
    final tempFilePickerDir = Directory(tempFilePickerDirPath);
    if (tempFilePickerDir.existsSync()) {
      await tempFilePickerDir.delete(recursive: true);
    }

    restoreRunning.value = false;
  }
}
