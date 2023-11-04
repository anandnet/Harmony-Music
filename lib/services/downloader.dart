import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '/services/permission_service.dart';
import '/ui/screens/settings_screen_controller.dart';
import '/utils/helper.dart';
import '/models/media_Item_builder.dart';
import '/services/music_service.dart';
import '/ui/utils/home_library_controller.dart';
import '../models/thumbnail.dart' as th;

class Downloader extends GetxService {
  MediaItem? currentSong;
  final downloadingProgress = 0.obs;
  final isJobRunning = false.obs;

  RxList<MediaItem> songQueue = <MediaItem>[].obs;

  Future<void> download(MediaItem song) async {
    if (!await PermissionService.getExtStoragePermission()) {
      return;
    }

    songQueue.add(song);
    if (isJobRunning.isFalse) {
      await triggerDownloadingJob();
    }
  }

  Future<void> triggerDownloadingJob() async {
    final streamClient = Get.find<MusicServices>().getStreamClient();
    final dirPath =
        Get.find<SettingsScreenController>().downloadLocationPath.string;
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final jobSongList = songQueue.toList();
    isJobRunning.value = true;

    for (MediaItem song in jobSongList) {
      currentSong = song;
      downloadingProgress.value = 0;
      await writeFileStream(streamClient, song);
      songQueue.remove(song);
      isJobRunning.value = false;
      currentSong = null;
      if (songQueue.isNotEmpty) {
        triggerDownloadingJob();
      }
    }
  }

  Future<void> writeFileStream(
      StreamClient streamClient, MediaItem song) async {
    Completer<void> complete = Completer();

    final songStreamManifest = await streamClient.getManifest(song.id);

    final settingsScreenController = Get.find<SettingsScreenController>();
    final downloadingFormat = settingsScreenController.downloadingFormat.string;
    final streamInfo = songStreamManifest.audioOnly.sortByBitrate().firstWhere(
        (element) => downloadingFormat == "opus"
            ? element.tag == 251
            : element.audioCodec.contains("mp4a"));
    final totalBytes = streamInfo.size.totalBytes;
    final stream = streamClient.get(streamInfo);
    final List<int> fileBytes = [];
    stream.listen((part) {
      fileBytes.addAll(part);
      downloadingProgress.value =
          ((fileBytes.length / totalBytes) * 100).toInt();
    }).onDone(() async {
      final dirPath = settingsScreenController.downloadLocationPath.string;

      String filePath = "$dirPath/${song.title}.$downloadingFormat";
      filePath = filePath
          .replaceAll("\"", "")
          .replaceAll(">", "")
          .replaceAll("<", "")
          .replaceAll("|", "");
      printINFO("Downloading filePath: $filePath");
      var file = File(filePath);

      await file.writeAsBytes(fileBytes);
      song.extras?['url'] = filePath;
      Hive.box("SongDownloads").put(song.id, MediaItemBuilder.toJson(song));
      Get.find<LibrarySongsController>().librarySongsList.add(song);
      printINFO("Downloaded successfully");
      try {
        final imageUrl = th.Thumbnail(song.artUri!.toString()).sizewith(540);
        Tag tag = Tag(
            title: song.title,
            trackArtist: song.artist,
            album: song.album,
            albumArtist: song.artist,
            genre: song.genre,
            pictures: [
              Picture(
                  bytes: (await NetworkAssetBundle(Uri.parse((imageUrl)))
                          .load(imageUrl))
                      .buffer
                      .asUint8List(),
                  mimeType: MimeType.none,
                  pictureType: PictureType.coverFront)
            ]);

        await AudioTags.write(filePath, tag);
      } catch (e) {
        printERROR("$e");
      }

      complete.complete();
    });

    return complete.future;
  }
}
