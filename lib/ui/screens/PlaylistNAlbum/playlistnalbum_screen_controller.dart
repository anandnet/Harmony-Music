import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../widgets/add_to_playlist.dart';
import '../../widgets/sort_widget.dart';
import '../Home/home_screen_controller.dart';
import '/services/piped_service.dart';
import '../../../utils/helper.dart';
import '/models/playlist.dart';
import '/models/album.dart';
import '../../../models/media_Item_builder.dart';
import '../../../services/music_service.dart';
import '../Library/library_controller.dart';

class PlayListNAlbumScreenController extends GetxController {
  final MusicServices _musicServices = Get.find<MusicServices>();
  late RxList<MediaItem> songList = RxList();
  final isContentFetched = false.obs;
  final isAddedToLibrary = false.obs;
  final isSearchingOn = false.obs;
  final isDownloaded = false.obs;
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;
  late final String id;
  late dynamic contentRenderer;
  late bool isAlbum;
  List<MediaItem> tempListContainer = [];
  dynamic box;

  @override
  void onReady() {
    final args = Get.arguments;
    if (args != null) {
      isAlbum = args[0];
      _init(args[1], args[0], args[2]);
    }
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
    super.onReady();
  }

  void _init(dynamic content, bool isAlbum, bool isIdOnly) {
    bool isPipedPlaylist = false;
    if (!isIdOnly) contentRenderer = content;
    id = (isIdOnly
        ? content
        : isAlbum
            ? content.browseId
            : content.playlistId);
    if (!isIdOnly && !isAlbum) {
      isPipedPlaylist = content.isPipedPlaylist;
      if (!content.isCloudPlaylist) {
        fetchSongsfromDatabase(id);
        return;
      }
    }

    _checkNFetchSongs(id, isIdOnly, isPipedPlaylist);
  }

  Future<void> _checkNFetchSongs(
      String id, bool isIdOnly, bool isPipedPlaylist) async {
    await _checkIfAddedToLibrary(id);
    if (isAddedToLibrary.isTrue) {
      final songsBox = await Hive.openBox(id);
      if (songsBox.values.isEmpty) {
        _fetchSong(id, isIdOnly, isPipedPlaylist).then((value) {
          updateSongsIntoDb();
        });
      } else {
        fetchSongsfromDatabase(id);
      }
    } else {
      _fetchSong(id, isIdOnly, isPipedPlaylist);
    }
  }

  Future<void> _checkIfAddedToLibrary(String id) async {
    //check
    box = isAlbum
        ? await Hive.openBox("LibraryAlbums")
        : await Hive.openBox("LibraryPlaylists");
    isAddedToLibrary.value = box.containsKey(id);
  }

  void addNRemoveItemsinList(MediaItem? item,
      {required String action, int? index}) {
    if (action == 'add') {
      if (tempListContainer.isNotEmpty) {
        index != null
            ? tempListContainer.insert(index, item!)
            : tempListContainer.add(item!);
        return;
      }
      index != null ? songList.insert(index, item!) : songList.add(item!);
    } else {
      if (tempListContainer.isNotEmpty) {
        index != null
            ? tempListContainer.removeAt(index)
            : tempListContainer.remove(item);
      }
      index != null ? songList.removeAt(index) : songList.remove(item);
    }
  }

  Future<void> updateSongsIntoDb() async {
    final songsBox = await Hive.openBox(id);
    await songsBox.clear();
    final songListCopy = songList.toList();
    for (int i = 0; i < songListCopy.length; i++) {
      await songsBox.put(i, MediaItemBuilder.toJson(songListCopy[i]));
    }
  }

  Future<void> fetchSongsfromDatabase(id) async {
    box = await Hive.openBox(id);
    final List<MediaItem> songList_ = box.values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList();
    songList.value = id == "LIBRP" ? songList_.reversed.toList() : songList_;
    isContentFetched.value = true;
    checkDownloadStatus();
  }

  Future<void> _fetchSong(
      String id, bool isIdOnly, bool isPipedPlaylist) async {
    isContentFetched.value = false;

    if (isPipedPlaylist) {
      songList.value = (await Get.find<PipedServices>().getPlaylistSongs(id));
      isContentFetched.value = true;
      checkDownloadStatus();
      return;
    }

    final content = isAlbum
        ? await _musicServices.getPlaylistOrAlbumSongs(albumId: id)
        : await _musicServices.getPlaylistOrAlbumSongs(playlistId: id);

    if (isIdOnly) {
      if (isAlbum) {
        content['browseId'] = id;
        final album =Album.fromJson(content);
        contentRenderer = album;
      } else {
        content['playlistId'] = id;
        final playlist = Playlist.fromJson(content);
        contentRenderer = playlist;
      }
    }
    songList.value = List<MediaItem>.from(content['tracks']);
    isContentFetched.value = true;
    checkDownloadStatus();
  }

  void syncPlaylistNAlbumSong() {
    _fetchSong(id, false, false).then((value) => updateSongsIntoDb());
  }

  /// Function for bookmark & add playlist to library
  Future<bool> addNremoveFromLibrary(dynamic content, {bool add = true}) async {
    try {
      if (!isAlbum && content.isPipedPlaylist && !add) {
        //remove piped playlist from lib
        final res =
            await Get.find<PipedServices>().deletePlaylist(content.playlistId);
        Get.find<LibraryPlaylistsController>().syncPipedPlaylist();
        return (res.code == 1);
      } else {
        final box = isAlbum
            ? await Hive.openBox("LibraryAlbums")
            : await Hive.openBox("LibraryPlaylists");
        final id = isAlbum ? content.browseId : content.playlistId;
        if (add) {
          box.put(id, content.toJson());
          updateSongsIntoDb();
        } else {
          box.delete(id);
          final songsBox = await Hive.openBox(id);
          songsBox.deleteFromDisk();
        }
        isAddedToLibrary.value = add;
      }
      //Update frontend
      isAlbum
          ? Get.find<LibraryAlbumsController>().refreshLib()
          : Get.find<LibraryPlaylistsController>().refreshLib();
      if (!isAlbum && !content.isCloudPlaylist && !add) {
        final plstbox = await Hive.openBox(content.playlistId);
        plstbox.deleteFromDisk();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void checkDownloadStatus() {
    bool downloaded = true;
    for (MediaItem item in songList) {
      if (!Hive.box("SongDownloads").containsKey(item.id)) {
        downloaded = false;
        break;
      }
    }
    isDownloaded.value = downloaded;
  }

  void onSort(SortType sortType, bool isAscending) {
    final songlist_ = songList.toList();
    sortSongsNVideos(songlist_, sortType, isAscending);
    songList.value = songlist_;
  }

  void onSearchStart(String? tag) {
    isSearchingOn.value = true;
    tempListContainer = songList.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    songList.value = songlist;
  }

  void onSearchClose(String? tag) {
    isSearchingOn.value = false;
    songList.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  //Additional operations
  final additionalOperationTempList = <MediaItem>[].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;

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

  void selectAll(bool selected) {
    for (int i = 0; i < additionalOperationTempList.length; i++) {
      additionalOperationTempMap[i] = selected;
    }
  }

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

  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {
    final isoffline = id == "SongsCache" || id == "SongDownloads";

    final box_ = await Hive.openBox(id);
    for (MediaItem element in songs) {
      final index = box_.values
          .toList()
          .indexWhere((ele) => ele['videoId'] == element.id);
      await box_.deleteAt(index);

      if (isoffline) {
        await Get.find<LibrarySongsController>()
            .removeSong(element, id == "SongDownloads");
      }

      songList.removeWhere((song) => song.id == element.id);
    }
    if (!isoffline) await box_.close();
  }

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

  void cancelAdditionalOperation() {
    sortWidgetController!.isAllSelected.value = false;
    sortWidgetController = null;
    additionalOperationMode.value = OperationMode.none;
    additionalOperationTempList.clear();
    additionalOperationTempMap.clear();
  }

  @override
  void onClose() {
    tempListContainer.clear();
    if (id != "SongDownloads") box.close();
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
    super.onClose();
  }
}
