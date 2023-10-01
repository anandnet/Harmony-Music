import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '/ui/navigator.dart';

void printERROR(dynamic text, {String tag = "Harmony Music"}) {
  debugPrint("\x1B[31m[$tag]: $text");
}

void printWarning(dynamic text, {String tag = 'Harmony Music'}) {
  debugPrint("\x1B[33m[$tag]: $text");
}

void printINFO(dynamic text, {String tag = 'Harmony Music'}) {
  debugPrint("\x1B[32m[$tag]: $text");
}

String? getCurrentRouteName() {
  String? currentPath;
  Get.nestedKey(ScreenNavigationSetup.id)?.currentState?.popUntil((route) {
    currentPath = route.settings.name;
    return true;
  });
  return currentPath;
}

void sortSongsNVideos(
  List songlist,
  bool sortByName,
  bool sortByDate,
  bool sortByDuration,
  bool isAscending,
) {
  if (sortByName) {
    songlist.sort((a, b) => isAscending
        ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
        : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
  } else if (sortByDate) {
    songlist.sort((a, b) {
      if (a.extras!['date'] == null || b.extras!['date'] == null) {
        return 0.compareTo(0);
      }
      return isAscending
          ? (a.extras!['date']).compareTo(b.extras!['date'])
          : (b.extras!['date']).compareTo(a.extras!['date']);
    });
  } else if (sortByDuration) {
    songlist.sort((a, b) => isAscending
        ? (a.duration ?? Duration.zero).compareTo(b.duration ?? Duration.zero)
        : (b.duration ?? Duration.zero).compareTo(a.duration ?? Duration.zero));
  }
}

void sortAlbumNSingles(
  List albumList,
  bool sortByName,
  bool sortByDate,
  bool isAscending,
) {
  if (sortByName) {
    albumList.sort((a, b) => isAscending
        ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
        : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
  } else if (sortByDate) {
    albumList.sort((a, b) {
      if (a.year == null || b.year == null) {
        return 0.compareTo(0);
      }
      return isAscending
          ? a.year!.compareTo(b.year!)
          : b.year!.compareTo(a.year!);
    });
  }
}

void sortPlayLists(
  List playlists,
  bool sortByName,
  bool isAscending,
) {
  playlists.sort((a, b) => isAscending
      ? a.title.toLowerCase().compareTo(b.title.toLowerCase())
      : b.title.toLowerCase().compareTo(a.title.toLowerCase()));
}

void sortArtist(
  List artistList,
  bool sortByName,
  bool isAscending,
) {
  artistList.sort((a, b) => isAscending
      ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
      : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
}

/// Return true if new version available
Future<bool> newVersionCheck(String currentVersion) async {
  final tags = (await Dio()
          .get("https://api.github.com/repos/anandnet/Harmony-Music/tags"))
      .data;
  final availableVersion = tags[0]['name'] as String;
  List currentVersion_ = currentVersion.substring(1).split(".");
  List availableVersion_ = availableVersion.substring(1).split(".");
  if (int.parse(availableVersion_[0]) > int.parse(currentVersion_[0])) {
    return true;
  } else if (int.parse(availableVersion_[1]) > int.parse(currentVersion_[1]) &&
      int.parse(availableVersion_[0]) == int.parse(currentVersion_[0])) {
    return true;
  } else if (int.parse(availableVersion_[2]) > int.parse(currentVersion_[2]) &&
      int.parse(availableVersion_[0]) == int.parse(currentVersion_[0]) &&
      int.parse(availableVersion_[1]) == int.parse(currentVersion_[1])) {
    return true;
  }
  return false;
}
