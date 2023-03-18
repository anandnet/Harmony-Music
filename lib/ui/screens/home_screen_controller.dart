import 'dart:developer';

import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/models/quick_picks.dart';
import 'package:harmonymusic/services/music_service.dart';

class HomeScreenController extends GetxController {
  final MusicServices _musicServices = Get.find<MusicServices>();
  final isContentFetched = false.obs;
  final homeContentList = [].obs;
  final tabIndex = 0.obs;
  HomeScreenController() {
    _init();
  }

  Future<void> _init() async {
    final homeContentListMap = await _musicServices.getHome(limit: 7);
    //debugPrint(homeContentListMap,wrapWidth: 1024);
    _setHomeContentList(homeContentListMap);
    isContentFetched.value = true;
  }

  void _setHomeContentList(List<dynamic> contents) {
    for (var content in contents) {
      if ((content["title"]).contains("Videos") ||
          (content["title"]).contains("videos")) {
      } else if (content["title"] == "Quick picks") {
        homeContentList.add(QuickPicks.fromJson(content));
      } else if (content["contents"][0].containsKey("playlistId")) {
        final tmp = PlaylistContent.fromJson(content);
        if (tmp.playlistList.length >= 2) {
          homeContentList.add(tmp);
        }
      } else if (content["contents"][0].containsKey("browseId")) {
        final tmp = AlbumContent.fromJson(content);
        if (tmp.albumList.length >= 2) {
          homeContentList.add(tmp);
        }
      }
    }
  }

  void onTabSelected(int index){
    tabIndex.value = index;
  }
  void getRelatedArtist() {}

  @override
  void onClose() {
    super.onClose();
  }
}
