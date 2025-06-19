import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/loader.dart';

import '../../services/permission_service.dart';
import 'common_dialog_widget.dart';

class ExportFileDialog extends StatelessWidget {
  const ExportFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final exportFileDialogController = Get.put(ExportFileDialogController());
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
                  "exportDowloadedFiles".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 150,
                child: Center(
                  child: Obx(() => exportFileDialogController.exportProgress
                              .toInt() ==
                          exportFileDialogController.filesToExport.length
                      ? Text("exportMsg".tr)
                      : exportFileDialogController.exportRunning.isTrue
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "${exportFileDialogController.exportProgress.toInt()}/${exportFileDialogController.filesToExport.length}",
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("exporting".tr)
                              ],
                            )
                          : exportFileDialogController.ready.isTrue
                              ? Text(
                                  "${exportFileDialogController.filesToExport.length} ${"downFilesFound".tr}")
                              : exportFileDialogController.scanning.isTrue
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
                        if (exportFileDialogController.exportProgress.toInt() ==
                            exportFileDialogController.filesToExport.length) {
                          Navigator.of(context).pop();
                        } else {
                          exportFileDialogController.export();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Obx(
                          () => Text(
                            exportFileDialogController.exportProgress.toInt() ==
                                    exportFileDialogController
                                        .filesToExport.length
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

class ExportFileDialogController extends GetxController {
  final scanning = true.obs;
  final ready = false.obs;
  final exportRunning = false.obs;
  final exportProgress = (-1).obs;
  List<String> filesToExport = [];

  @override
  void onInit() {
    scanFilesToExport();
    super.onInit();
  }

  Future<void> scanFilesToExport() async {
    final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;
    final filesEntityList =
        Directory("$supportDirPath/Music").listSync(recursive: false);
    final filesPath = filesEntityList.map((entity) => entity.path).toList();
    filesToExport.addAll(filesPath);
    scanning.value = false;
    ready.value = true;
  }

  Future<void> export() async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    exportProgress.value = 0;
    exportRunning.value = true;
    final exportDirPath =
        Get.find<SettingsScreenController>().exportLocationPath.toString();
    final length_ = filesToExport.length;
    for (int i = 0; i < length_; i++) {
      final filePath = filesToExport[i];
      final newFilePath = "$exportDirPath/${filePath.split("/").last}";
      await File(filePath).copy(newFilePath);
      exportProgress.value = i + 1;
    }
    exportRunning.value = false;
  }
}
