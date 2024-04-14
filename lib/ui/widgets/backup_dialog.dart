import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';

import '../../services/permission_service.dart';
import 'common_dialog_widget.dart';

class BackupDialog extends StatelessWidget {
  const BackupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final backupDialogController = Get.put(BackupDialogController());
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
                  "backupSettingsAndPlaylists".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 150,
                child: Center(
                  child: Obx(() => backupDialogController.exportProgress
                              .toInt() ==
                          backupDialogController.filesToExport.length
                      ? Text("backupMsg".tr)
                      : backupDialogController.exportRunning.isTrue
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "${backupDialogController.exportProgress.toInt()}/${backupDialogController.filesToExport.length}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("exporting".tr)
                              ],
                            )
                          : backupDialogController.ready.isTrue
                              ? Text(
                                  "${backupDialogController.filesToExport.length} ${"backFilesFound".tr}")
                              : backupDialogController.scanning.isTrue
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const LoadingIndicator(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text("scanning".tr)
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
                        if (backupDialogController.exportProgress.toInt() ==
                            backupDialogController.filesToExport.length) {
                          Navigator.of(context).pop();
                        } else {
                          backupDialogController.backup();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Obx(
                          () => Text(
                            backupDialogController.exportProgress.toInt() ==
                                    backupDialogController.filesToExport.length
                                ? "close".tr
                                : "export".tr,
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

class BackupDialogController extends GetxController {
  final scanning = true.obs;
  final ready = false.obs;
  final exportRunning = false.obs;
  final exportProgress = (-1).obs;
  List<String> filesToExport = [];

  @override
  void onInit() {
    scanFilesToBackup();
    super.onInit();
  }

  Future<void> scanFilesToBackup() async {
    final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;
    final filesEntityList =
        Directory("$supportDirPath/db").listSync(recursive: false);
    final filesPath = filesEntityList.map((entity) => entity.path).toList();
    filesToExport.addAll(filesPath);
    scanning.value = false;
    ready.value = true;
  }

  Future<void> backup() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    final String? pickedFolderPath = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Select backup file folder");
    if (pickedFolderPath == '/' || pickedFolderPath == null) {
      return;
    }

    exportProgress.value = 0;
    exportRunning.value = true;
    final exportDirPath = pickedFolderPath.toString();

    var encoder = ZipFileEncoder();
    encoder.create(
        '$exportDirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.hmb');
    final length_ = filesToExport.length;
    for (int i = 0; i < length_; i++) {
      final filePath = filesToExport[i];
      await encoder.addFile(File(filePath));
      exportProgress.value = i + 1;
    }
    encoder.close();
    exportRunning.value = false;
  }
}
