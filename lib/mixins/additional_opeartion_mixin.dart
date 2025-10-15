import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/base_class/playlist_album_screen_con_base.dart';

import '../ui/widgets/add_to_playlist.dart';
import '../ui/widgets/sort_widget.dart';
import '../utils/helper.dart';

mixin AdditionalOpeartionMixin on PlaylistAlbumScreenControllerBase {
  // This mixin is used to handle additional operations like sorting, searching, and performing actions on a list of songs.
  // It is used in various screens like Album, Playlist, and SongsCache.
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;
  final isSearchingOn = false.obs;
  List<MediaItem> tempListContainer = <MediaItem>[];

  void onSort(SortType sortType, bool isAscending) {
    final songlist_ = songList.toList();
    sortSongsNVideos(songlist_, sortType, isAscending);
    songList.value = songlist_;
  }

  @override
  void onSearchStart(String? tag) {
    isSearchingOn.value = true;
    tempListContainer = songList.toList();
  }

  @override
  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    songList.value = songlist;
  }

  @override
  void onSearchClose(String? tag) {
    isSearchingOn.value = false;
    songList.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  //Additional operations
  final additionalOperationTempList = <MediaItem>[].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;

  @override
  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode) {
    sortWidgetController = sortWidgetController_;
    additionalOperationTempList.value = songList.toList();
    if (mode == OperationMode.addToPlaylist || mode == OperationMode.delete) {
      for (int i = 0; i < additionalOperationTempList.length; i++) {
        additionalOperationTempMap[i] = false;
      }
    }
    additionalOperationMode.value = mode;
  }

  void checkIfAllSelected() {
    sortWidgetController!.isAllSelected.value =
        !additionalOperationTempMap.containsValue(false);
  }

  @override
  void selectAll(bool selectAll) {
    for (int i = 0; i < additionalOperationTempList.length; i++) {
      additionalOperationTempMap[i] = selectAll;
    }
  }

  @override
  void performAdditionalOperation() {
    final currMode = additionalOperationMode.value;
    if (currMode == OperationMode.arrange) {
      songList.value = additionalOperationTempList.toList();
      updateSongsIntoDb().then((value) {
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
    } else if (currMode == OperationMode.delete) {
      deleteMultipleSongs(selectedSongs()).then((value) {
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
    } else if (currMode == OperationMode.addToPlaylist) {
      showDialog(
        context: Get.context!,
        builder: (context) => AddToPlaylist(selectedSongs()),
      ).whenComplete(() {
        Get.delete<AddToPlaylistController>();
        sortWidgetController?.setActiveMode(OperationMode.none);
        cancelAdditionalOperation();
      });
    }
  }

  @override
  List<MediaItem> selectedSongs() {
    return additionalOperationTempMap.entries
        .map((item) {
          if (item.value) {
            return additionalOperationTempList[item.key];
          }
        })
        .whereType<MediaItem>()
        .toList();
  }

  @override
  void cancelAdditionalOperation() {
    sortWidgetController!.isAllSelected.value = false;
    sortWidgetController = null;
    additionalOperationMode.value = OperationMode.none;
    additionalOperationTempList.clear();
    additionalOperationTempMap.clear();
  }
}
