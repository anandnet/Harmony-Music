import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiotags/audiotags.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/playlistnalbum_screen_controller.dart';
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
  RxMap<String, List<MediaItem>> playlistQueue =
      <String, List<MediaItem>>{}.obs;
  final currentPlaylistId = "".obs;
  final songDownloadingProgress = 0.obs;
  final playlistDownloadingProgress = 0.obs;
  final isJobRunning = false.obs;

  RxList<MediaItem> songQueue = <MediaItem>[].obs;
  final streamClient = Get.find<MusicServices>().getStreamClient();

  Future<bool> checkPermissionNDir() async {
    final settingsScreenController =
        Get.find<SettingsScreenController>();

    if (!settingsScreenController.isCurrentPathsupportDownDir && !await PermissionService.getExtStoragePermission()) {
      return false;
    }

    final dirPath =
        Get.find<SettingsScreenController>().downloadLocationPath.string;
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return true;
  }

  Future<void> downloadPlaylist(
      String playlistId, List<MediaItem> songList) async {
    if(!(await checkPermissionNDir())) return;
    playlistQueue[playlistId] = songList;
    songQueue.addAll(songList);

    if (isJobRunning.isFalse) {
      await triggerDownloadingJob();
    }
  }

  Future<void> download(MediaItem? song, {List<MediaItem>? songList}) async {
    if (!(await checkPermissionNDir())) return;
    if (songList != null) {
      songQueue.addAll(songList);
    } else {
      songQueue.add(song!);
    }
    if (isJobRunning.isFalse) {
      await triggerDownloadingJob();
    }
  }

  Future<void> triggerDownloadingJob() async {
    //check if playlist download in queue => download playlistsongs else download from general songs queue
    if (playlistQueue.isNotEmpty) {
      isJobRunning.value = true;
      for (String playlistId in playlistQueue.keys.toList()) {
        currentPlaylistId.value = playlistId;
        await downloadSongList((playlistQueue[playlistId]!).toList(),
            isPlaylist: true);
        playlistQueue.remove(playlistId);
        if (Get.isRegistered<PlayListNAlbumScreenController>(
            tag: Key(playlistId).hashCode.toString())) {
          Get.find<PlayListNAlbumScreenController>(
                  tag: Key(playlistId).hashCode.toString())
              .isDownloaded
              .value = true;
        }
      }
      currentPlaylistId.value = "";
      playlistDownloadingProgress.value = 0;
    } else {
      isJobRunning.value = true;
      await downloadSongList(songQueue.toList());
    }

    if (songQueue.isNotEmpty) {
      triggerDownloadingJob();
    } else {
      isJobRunning.value = false;
      currentSong = null;
    }
  }

  Future<void> downloadSongList(List<MediaItem> jobSongList,
      {bool isPlaylist = false}) async {
    for (MediaItem song in jobSongList) {
      if (!Hive.box("SongDownloads").containsKey(song.id)) {
        currentSong = song;
        songDownloadingProgress.value = 0;
        await writeFileStream(streamClient, song);
      }
      songQueue.remove(song);
      //for playlist downloading counter update
      if (isPlaylist) {
        playlistDownloadingProgress.value = jobSongList.indexOf(song) + 1;
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
      songDownloadingProgress.value =
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
