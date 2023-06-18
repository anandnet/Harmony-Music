import 'package:flutter/foundation.dart';


void printERROR(dynamic text, {String tag = "Harmony Music"}) {
  debugPrint("\x1B[31m[$tag]: $text");
}

void printWarning(dynamic text, {String tag = 'Harmony Music'}) {
  debugPrint("\x1B[33m[$tag]: $text");
}

void printINFO(dynamic text, {String tag = 'Harmony Music'}) {
  debugPrint("\x1B[32m[$tag]: $text");
}

void sortSongsNVideos(
  List songlist,
  bool sortByName,
  bool sortByDate,
  bool sortByDuration,
  bool isAscending,
) {
  if (sortByName) {
    songlist.sort((a, b) =>
        isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
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
    albumList.sort((a, b) =>
        isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
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
  playlists.sort((a, b) =>
      isAscending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
}

void sortArtist(
  List artistList,
  bool sortByName,
  bool isAscending,
) {
  artistList.sort((a, b) =>
      isAscending ? a.name.compareTo(b.name) : b.name.compareTo(a.name));
}
