import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '/ui/screens/Settings/settings_screen_controller.dart';
import '/ui/widgets/loader.dart';
import '/utils/helper.dart';
import '../../services/permission_service.dart';
import 'common_dialog_widget.dart';

class BackupDialog extends StatelessWidget {
  const BackupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final backupDialogController = Get.put(BackupDialogController());
    return CommonDialog(
      child: Container(
        height: GetPlatform.isAndroid ? 350 : 300,
        padding:
            const EdgeInsets.only(top: 20, bottom: 30, left: 20, right: 20),
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10),
                child: Text(
                  "backupAppData".tr,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 100,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => (backupDialogController.scanning.isTrue ||
                              backupDialogController.backupRunning.isTrue)
                          ? const LoadingIndicator()
                          : const SizedBox.shrink()),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Obx(() => Text(
                                backupDialogController.scanning.isTrue
                                    ? "scanning".tr
                                    : backupDialogController
                                            .backupRunning.isTrue
                                        ? "backupInProgress".tr
                                        : backupDialogController
                                                .isbackupCompleted.isTrue
                                            ? "backupMsg".tr
                                            : "letsStrart".tr,
                                textAlign: TextAlign.center,
                              )),
                          if (GetPlatform.isAndroid)
                            Obx(() => (backupDialogController
                                    .isDownloadedfilesSeclected.isTrue)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "androidBackupWarning".tr,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox.shrink())
                        ],
                      )
                    ],
                  )),
                ),
              ),
              if (!GetPlatform.isDesktop)
                Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: backupDialogController
                                  .isDownloadedfilesSeclected.value,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              onChanged:
                                  backupDialogController.scanning.isTrue ||
                                          backupDialogController
                                              .backupRunning.isTrue ||
                                          backupDialogController
                                              .isbackupCompleted.isTrue
                                      ? null
                                      : (bool? value) {
                                          backupDialogController
                                              .isDownloadedfilesSeclected
                                              .value = value!;
                                        },
                            ),
                            Text("includeDownloadedFiles".tr),
                          ]),
                    )),
              SizedBox(
                width: double.maxFinite,
                child: Align(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.titleLarge!.color,
                        borderRadius: BorderRadius.circular(10)),
                    child: InkWell(
                      onTap: () {
                        if (backupDialogController.isbackupCompleted.isTrue) {
                          Navigator.of(context).pop();
                        } else {
                          backupDialogController.backup();
                        }
                      },
                      child: Obx(
                        () => Visibility(
                          visible:
                              !(backupDialogController.backupRunning.isTrue ||
                                  backupDialogController.scanning.isTrue),
                          replacement: const SizedBox(
                            height: 40,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10),
                            child: Obx(
                              () => Text(
                                backupDialogController.isbackupCompleted.isTrue
                                    ? "close".tr
                                    : "backup".tr,
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

class BackupDialogController extends GetxController {
  final scanning = false.obs;
  final isbackupCompleted = false.obs;
  final backupRunning = false.obs;
  final isDownloadedfilesSeclected = false.obs;
  List<String> filesToExport = [];
  final supportDirPath = Get.find<SettingsScreenController>().supportDirPath;

  Future<void> scanFilesToBackup() async {
    final dbDir = await Get.find<SettingsScreenController>().dbDir;
    filesToExport.addAll(await processDirectoryInIsolate(dbDir));
    if (isDownloadedfilesSeclected.value) {
      List<String> downlodedSongFilePaths = Hive.box("SongDownloads")
          .values
          .map<String>((data) => data['url'])
          .toList();
      filesToExport.addAll(downlodedSongFilePaths);
      try {
        filesToExport.addAll(await processDirectoryInIsolate(
            "$supportDirPath/thumbnails",
            extensionFilter: ".png"));
      } catch (e) {
        printERROR(e);
      }
    }
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

    scanning.value = true;
    await Future.delayed(const Duration(seconds: 4));
    await scanFilesToBackup();
    scanning.value = false;

    backupRunning.value = true;
    final exportDirPath = pickedFolderPath.toString();

    compressFilesInBackground(filesToExport,
            '$exportDirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.hmb')
        .then((_) {
      backupRunning.value = false;
      isbackupCompleted.value = true;
    }).catchError((e) {
      printERROR('Error during compression: $e');
    });
  }
}

// Function to convert file paths to base64-encoded file data
List<String> filePathsToBase64(List<String> filePaths) {
  List<String> base64Data = [];

  for (String path in filePaths) {
    try {
      // Read the file data as bytes
      File file = File(path);
      List<int> fileData = file.readAsBytesSync();
      // Convert bytes to base64
      String base64String = base64Encode(fileData);
      base64Data.add(base64String);
    } catch (e) {
      printERROR('Error reading file $path: $e');
    }
  }

  return base64Data;
}

// Function to convert file paths to file data (List<int>)
List<List<int>> filePathsToFileData(List<String> filePaths) {
  List<List<int>> filesData = [];

  for (String path in filePaths) {
    try {
      // Read the file data as bytes
      File file = File(path);
      List<int> fileData = file.readAsBytesSync();
      filesData.add(fileData);
    } catch (e) {
      printERROR('Error reading file $path: $e');
    }
  }

  return filesData;
}

// Function to compress files (to be used with compute or isolate)
void _compressFiles(Map<String, dynamic> params) {
  final List<List<int>> filesData = params['filesData'];
  final List<String> fileNames = params['fileNames'];
  final String zipFilePath = params['zipFilePath'];

  final archive = Archive();

  for (int i = 0; i < filesData.length; i++) {
    final fileData = filesData[i];
    final fileName = fileNames[i];
    final file = ArchiveFile(fileName, fileData.length, fileData);
    archive.addFile(file);
  }

  final encoder = ZipEncoder();
  final zipFile = File(zipFilePath);
  zipFile.writeAsBytesSync(encoder.encode(archive)!);
}

// Example usage
Future<void> compressFilesInBackground(
    List<String> filePaths, String zipFilePath) async {
  // Convert file paths to file data
  final List<List<int>> filesData = filePathsToFileData(filePaths);
  final List<String> fileNames = filePaths
      .map((path) => path.split(GetPlatform.isWindows ? '\\' : '/').last)
      .toList();

  printINFO(fileNames);
  // Use compute to run the compression in the background
  await compute(_compressFiles, {
    'filesData': filesData,
    'fileNames': fileNames,
    'zipFilePath': zipFilePath,
  });
}

Future<List<String>> processDirectoryInIsolate(String dbDir,
    {String extensionFilter = ".hive"}) async {
  // Use Isolate.run to execute the function in a new isolate
  return await Isolate.run(() async {
    // List files in the directory
    final filesEntityList =
        await Directory(dbDir).list(recursive: false).toList();

    // Filter out .hive files
    final filesPath = filesEntityList
        .whereType<File>() // Ensure we only work with files
        .map((entity) {
          if (entity.path.endsWith(extensionFilter)) return entity.path;
        })
        .whereType<String>()
        .toList();

    return filesPath;
  });
}
