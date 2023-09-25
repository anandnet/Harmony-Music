import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../utils/update_check_flag_file.dart';
import '../../utils/helper.dart';
import '/models/album.dart';
import '/models/playlist.dart';
import '/models/quick_picks.dart';
import '/services/music_service.dart';
import '/ui/screens/settings_screen_controller.dart';
import '/ui/widgets/new_version_dialog.dart';

class HomeScreenController extends GetxController {
  final MusicServices _musicServices = Get.find<MusicServices>();
  final isContentFetched = false.obs;
  final tabIndex = 0.obs;
  final networkError = false.obs;
  final quickPicks = QuickPicks([]).obs;
  final middleContent = [].obs;
  final fixedContent = [].obs;
  final showVersionDialog = true.obs;

  @override
  onInit() {
    super.onInit();
    init();
    if (updateCheckFlag) _checkNewVersion();
  }

  Future<void> init() async {
    final box = Hive.box("AppPrefs");
    String contentType = box.get("discoverContentType") ?? "QP";

    networkError.value = false;
    try {
      List middleContentTemp = [];
      final homeContentListMap = await _musicServices.getHome(limit: 10);
      if (contentType == "TR") {
        final index = homeContentListMap
            .indexWhere((element) => element['title'] == "Trending");
        if (index != -1 && index != 0) {
          quickPicks.value = QuickPicks(
              List<MediaItem>.from(homeContentListMap[index]["contents"]),
              title: "Trending");
        } else if (index == -1) {
          List charts = await _musicServices.getCharts();
          final con =
              charts.length == 4 ? charts.removeAt(3) : charts.removeAt(2);
          quickPicks.value = QuickPicks(List<MediaItem>.from(con["contents"]),
              title: con['title']);
          middleContentTemp.addAll(charts);
        }
      } else if (contentType == "TMV") {
        final index = homeContentListMap
            .indexWhere((element) => element['title'] == "Top music videos");
        if (index != -1 && index != 0) {
          final con = homeContentListMap.removeAt(index);
          quickPicks.value = QuickPicks(List<MediaItem>.from(con["contents"]),
              title: con["title"]);
        } else if (index == -1) {
          List charts = await _musicServices.getCharts();
          quickPicks.value = QuickPicks(
              List<MediaItem>.from(charts[0]["contents"]),
              title: charts[0]["title"]);
          middleContentTemp.addAll(charts.sublist(1));
        }
      } else if (contentType == "BOLI") {
        final songId = box.get("recentSongId");
        if (songId != null) {
          final rel = (await _musicServices.getContentRelatedToSong(songId));
          final con = rel.removeAt(0);
          quickPicks.value = QuickPicks(List<MediaItem>.from(con["contents"]));
          middleContentTemp.addAll(rel);
        }
      } else if (quickPicks.value.songList.isEmpty) {
        final index = homeContentListMap
            .indexWhere((element) => element['title'] == "Quick picks");
        final con = homeContentListMap.removeAt(index);
        quickPicks.value = QuickPicks(List<MediaItem>.from(con["contents"]),
            title: "Quick picks");
      }
      middleContent.value = _setContentList(middleContentTemp);
      fixedContent.value = _setContentList(homeContentListMap);

      isContentFetched.value = true;
      // ignore: unused_catch_stack
    } on NetworkError catch (_, e) {
      printERROR("Home Content not loaded due to ${_.message}");
      await Future.delayed(const Duration(seconds: 1));
      networkError.value = true;
    }
  }

  List _setContentList(
    List<dynamic> contents,
  ) {
    List contentTemp = [];
    for (var content in contents) {
      if ((content["contents"][0]).runtimeType == Playlist) {
        final tmp = PlaylistContent(
            playlistList: (content["contents"]).whereType<Playlist>().toList(),
            title: content["title"]);
        if (tmp.playlistList.length >= 2) {
          contentTemp.add(tmp);
        }
      } else if ((content["contents"][0]).runtimeType == Album) {
        final tmp = AlbumContent(
            albumList: (content["contents"]).whereType<Album>().toList(),
            title: content["title"]);
        if (tmp.albumList.length >= 2) {
          contentTemp.add(tmp);
        }
      }
    }
    return contentTemp;
  }

  Future<void> changeDiscoverContent(dynamic val, {String? songId}) async {
    QuickPicks? quickPicks_;
    if (val == 'QP') {
      final homeContentListMap = await _musicServices.getHome(limit: 3);
      quickPicks_ = QuickPicks(
          List<MediaItem>.from(homeContentListMap[0]["contents"]),
          title: homeContentListMap[0]["title"]);
    } else if (val == "TMV" || val == 'TR') {
      final charts = await _musicServices.getCharts();
      final index = val == "TMV"
          ? 0
          : charts.length == 4
              ? 3
              : 2;
      quickPicks_ = QuickPicks(List<MediaItem>.from(charts[index]["contents"]),
          title: charts[index]["title"]);
    } else {
      songId ??= Hive.box("AppPrefs").get("recentSongId");
      if (songId != null) {
        final value = await _musicServices.getContentRelatedToSong(songId);
        middleContent.value = _setContentList(value);
        if ((value[0]['title']).contains("like")) {
          quickPicks_ = QuickPicks(List<MediaItem>.from(value[0]["contents"]));
        }
        Hive.box("AppPrefs").put("recentSongId", songId);
      }
    }
    if (quickPicks_ == null) return;

    quickPicks.value = quickPicks_;
  }

  void onTabSelected(int index) {
    tabIndex.value = index;
  }

  void _checkNewVersion() {
    showVersionDialog.value =
        Hive.box("AppPrefs").get("newVersionVisibility") ?? true;
    if (showVersionDialog.isTrue) {
      newVersionCheck(Get.find<SettingsScreenController>().currentVersion)
          .then((value) {
        if (value) {
          showDialog(
              context: Get.context!,
              builder: (context) => const NewVersionDialog());
        }
      });
    }
  }

  void onChangeVersionVisibility(bool val) {
    Hive.box("AppPrefs").put("newVersionVisibility", !val);
    showVersionDialog.value = !val;
  }
}
