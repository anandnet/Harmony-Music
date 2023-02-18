import 'dart:developer';

import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/models/quick_picks.dart';
import 'package:harmonymusic/models/song.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/song_stream_url_service.dart';

class HomeScreenController extends GetxController {
  late MusicServices _musicServices;
  final isContentFetched = false.obs;
  final homeContentList = [].obs;
  HomeScreenController() {
    _init();
  }

  Future<void> _init() async {
    _musicServices = MusicServices();
    final homeContentListMap = await _musicServices.getHome(limit: 7);
    setHomeContentList(homeContentListMap);
    isContentFetched.value = true;
  }

  void setHomeContentList(List<dynamic> contents) {
    for (var content in contents) {
      if ((content["title"]).contains("Videos") ||
          (content["title"]).contains("videos")) {
      } else if (content["title"] == "Quick picks") {
        homeContentList.add(QuickPicks.fromJson(content));
      } else if (content["contents"][0].containsKey("playlistId")) {
        homeContentList.add(PlaylistContent.fromJson(content));
      } else if (content["contents"][0].containsKey("browseId")) {
        homeContentList.add(AlbumContent.fromJson(content));
      }
    }
  }

  void getRelatedArtist() {}
}
