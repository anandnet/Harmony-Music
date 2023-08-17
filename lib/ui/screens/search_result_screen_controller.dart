import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helper.dart';
import '/services/music_service.dart';

class SearchResultScreenController extends GetxController {
  final navigationRailCurrentIndex = 0.obs;
  final isResultContentFetced = false.obs;
  final isSeparatedResultContentFetced = false.obs;
  final resultContent = <String, dynamic>{}.obs;
  final separatedResultContent = <String, dynamic>{}.obs;
  final musicServices = Get.find<MusicServices>();
  final queryString = ''.obs;
  final railItems = <String>[].obs;
  final railitemHeight = Get.size.height.obs;
  final additionalParamNext = {};
  bool continuationInProgress = false;

  //ScrollContollers List
  final Map<String, ScrollController> scrollControllers = {};

  @override
  void onInit() async {
    _getInitSearchResult();
    super.onInit();
  }

  Future<void> onDestinationSelected(int value) async {
    if (railItems.isEmpty) {
      return;
    }

    isSeparatedResultContentFetced.value = false;
    navigationRailCurrentIndex.value = value;
    if (value != 0 &&
        !separatedResultContent.containsKey(railItems[value - 1])) {
      final tabName = railItems[value - 1];
      final itemCount = (tabName == 'Songs' || tabName == 'Videos') ? 25 : 10;
      final x = await musicServices.search(queryString.value,
          filter: tabName.replaceAll(" ", "_").toLowerCase(), limit: itemCount);
      separatedResultContent[tabName] = x[tabName];
      additionalParamNext[tabName] = x['params'];
      isSeparatedResultContentFetced.value = true;
      final scrollController = scrollControllers[tabName];
      (scrollController)!.addListener(() {
        double maxScroll = scrollController.position.maxScrollExtent;
        double currentScroll = scrollController.position.pixels;
        if (currentScroll >= maxScroll / 2 &&
            additionalParamNext[tabName]['additionalParams'] !=
                '&ctoken=null&continuation=null') {
          if (!continuationInProgress) {
            printINFO("Acchhsk");
            continuationInProgress = true;
            getContinuationContents();
          }
        }
      });
    }
    isSeparatedResultContentFetced.value = true;
  }

  Future<void> getContinuationContents() async {
    final tabName = railItems[navigationRailCurrentIndex.value - 1];

    final x =
        await musicServices.getSearchContinuation(additionalParamNext[tabName]);
    (separatedResultContent[tabName]).addAll(x[tabName]);
    additionalParamNext[tabName] = x['params'];
    separatedResultContent.refresh();

    continuationInProgress = false;
  }

  void viewAllCallback(String text) {
    onDestinationSelected(railItems.indexOf(text) + 1);
  }

  Future<void> _getInitSearchResult() async {
    isResultContentFetced.value = false;
    final args = Get.arguments;
    if (args != null) {
      queryString.value = args;
      resultContent.value = await musicServices.search(args);
      final allKeys = resultContent.keys.where((element) => ([
            "Songs",
            "Videos",
            "Albums",
            "Featured playlists",
            "Community playlists",
            "Artists"
          ]).contains(element));
      railItems.value = List<String>.from(allKeys);
      final len =
          railItems.where((element) => element.contains("playlists")).length;
      final calH = 30 + (railItems.length + 1 - len) * 123 + len * 150.0;
      railitemHeight.value =
          calH >= railitemHeight.value ? calH : railitemHeight.value;

      //ScrollControlers for list Continuation callback implementarion
      for (String item in railItems) {
        scrollControllers[item] = ScrollController();
      }
      isResultContentFetced.value = true;
    }
  }

  void onSort(bool sortByName, bool sortByDate, bool sortByDuration,
      bool isAscending, String title) {
    if (title == "Songs" || title == "Videos") {
      final songList = separatedResultContent[title].toList();
      sortSongsNVideos(
          songList, sortByName, sortByDate, sortByDuration, isAscending);
      separatedResultContent[title] = songList;
    } else if (title.contains('playlists')) {
      final playlists = separatedResultContent[title].toList();
      sortPlayLists(playlists, sortByName, isAscending);
      separatedResultContent[title] = playlists;
    } else if (title == "Artists") {
      final artistList = separatedResultContent[title].toList();
      sortArtist(artistList, sortByName, isAscending);
      separatedResultContent[title] = artistList;
    } else if (title == "Albums") {
      final albumList = separatedResultContent[title].toList();
      sortAlbumNSingles(albumList, sortByName, sortByDate, isAscending);
      separatedResultContent[title] = albumList;
    }
  }

  @override
  void onClose() {
    for (String item in railItems) {
      (scrollControllers[item])!.dispose();
    }
    super.onClose();
  }
}
