import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

import '../../../utils/house_keeping.dart';
import '../../widgets/add_to_playlist.dart';
import '/ui/widgets/sort_widget.dart';
import '../Settings/settings_screen_controller.dart';
import '/services/piped_service.dart';
import '../../../utils/helper.dart';
import '/models/album.dart';
import '/models/artist.dart';
import '/models/media_Item_builder.dart';
import '/models/playlist.dart';

class LibrarySongsController extends GetxController {
  late RxList<MediaItem> librarySongsList = RxList();
  final isSongFetched = false.obs;
  List<MediaItem> tempListContainer = [];
  SortWidgetController? sortWidgetController;
  final additionalOperationMode = OperationMode.none.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> init() async {
    // Make sure that song cached in system or not cleared by system
    // if cleared then it will remove from database as well
    List<String> songsList = [];
    final cacheDir = (await getTemporaryDirectory()).path;
    if (Directory("$cacheDir/cachedSongs/").existsSync()) {
      final downloadedFiles = Directory("$cacheDir/cachedSongs")
          .listSync()
          .where((f) => !['mime', 'part']
              .contains(f.path.replaceAll(RegExp(r'^.*\.'), '')));
      songsList.addAll(downloadedFiles
          .map((e) {
            RegExpMatch? match =
                RegExp(".cachedSongs/([^#]*)?.mp3").firstMatch(e.path);
            if (match != null) {
              return match[1]!;
            }
          })
          .whereType<String>()
          .toList());
      //printINFO("all files: $downloadedFiles \n $songsList");
    }

    final box = Hive.box("SongsCache");
    for (var element in box.keys) {
      if (!songsList.contains(element)) {
        box.delete(element);
      }
    }

    librarySongsList.value = box.values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList();

    librarySongsList.addAll(Hive.box("SongDownloads")
        .values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList());
    isSongFetched.value = true;

    //Remove deleted songs and expired songUrl from database
    startHouseKeeping();
  }

  void onSort(SortType sortType, bool isAscending) {
    final songlist = librarySongsList.toList();
    sortSongsNVideos(songlist, sortType, isAscending);
    librarySongsList.value = songlist;
  }

  void onSearchStart(String? tag) {
    tempListContainer = librarySongsList.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    librarySongsList.value = songlist;
  }

  void onSearchClose(String? tag) {
    librarySongsList.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  /// remove song from library list and from storage only, not from database
  Future<void> removeSong(MediaItem item, bool isDownloaded,
      {String? url}) async {
    if (tempListContainer.isNotEmpty) {
      tempListContainer.remove(item);
    }
    librarySongsList.remove(item);
    String filePath = "";
    if (isDownloaded) {
      filePath = item.extras!['url'] ?? url;
    } else {
      final cacheDir = (await getTemporaryDirectory()).path;
      filePath = "$cacheDir/cachedSongs/${item.id}.mp3";
    }

    if (await (File(filePath)).exists()) {
      await (File(filePath)).delete();
    }

    final thumbFile = File(
        "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${item.id}.png");
    if (await thumbFile.exists()) {
      await thumbFile.delete();
    }
  }

//Additional operations
  final additionalOperationTempList = [].obs;
  final additionalOperationTempMap = <int, bool>{}.obs;

  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode) {
    sortWidgetController = sortWidgetController_;
    additionalOperationTempList.value = librarySongsList.toList();
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
    if (currMode == OperationMode.delete) {
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
    final downloadsBox = await Hive.openBox("SongDownloads");
    final cacheBox = await Hive.openBox("SongsCache");
    for (MediaItem element in songs) {
      if (downloadsBox.containsKey(element.id)) {
        await downloadsBox.delete(element.id);
        removeSong(element, true);
      } else {
        await cacheBox.delete(element.id);
        removeSong(element, false);
      }
    }
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
}

class LibraryPlaylistsController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController controller;

  final playlistCreationMode = "local".obs;
  static final initPlst = [
    Playlist(
        title: "recentlyPlayed".tr,
        playlistId: "LIBRP",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "favorites".tr,
        playlistId: "LIBFAV",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "cachedOrOffline".tr,
        playlistId: "SongsCache",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false),
    Playlist(
        title: "downloads".tr,
        playlistId: "SongDownloads",
        thumbnailUrl: Playlist.thumbPlaceholderUrl,
        isCloudPlaylist: false)
  ];
  late RxList<Playlist> libraryPlaylists = RxList(initPlst);
  final isContentFetched = false.obs;
  final creationInProgress = false.obs;
  final textInputController = TextEditingController();
  List<Playlist> tempListContainer = [];

  // Add these RxBool to track import progress
  final isImporting = false.obs;
  final importProgress = 0.0.obs;

  @override
  void onInit() {
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    refreshLib();
    super.onInit();
  }

  void refreshLib() async {
    final box = await Hive.openBox("LibraryPlaylists");
    libraryPlaylists.value = [
      ...initPlst,
      ...(box.values
          .map<Playlist?>((item) => Playlist.fromJson(item))
          .whereType<Playlist>()
          .toList())
    ];

    final appPrefsBox = Hive.box("AppPrefs");
    if (appPrefsBox.containsKey("piped")) {
      if (appPrefsBox.get("piped")['isLoggedIn']) await syncPipedPlaylist();
    }

    isContentFetched.value = true;
    await box.close();
  }

  void updatePlaylistIntoDb(Playlist playlist) async {
    final box = await Hive.openBox("LibraryPlaylists");
    box.put(playlist.playlistId, playlist.toJson());
    refreshLib();
  }

  void removePipedPlaylists() {
    for (Playlist plst in libraryPlaylists.toList()) {
      if (plst.isPipedPlaylist) {
        libraryPlaylists.remove(plst);
      }
    }
  }

  Future<void> syncPipedPlaylist() async {
    final res = await Get.find<PipedServices>().getAllPlaylists();
    final box = await Hive.openBox('blacklistedPlaylist');
    final blacklistedPlaylist = box.values.whereType<String>().toList();
    final libPipedPlaylistsId = libraryPlaylists
            .toList()
            .map((e) {
              if (e.isPipedPlaylist) {
                return e.playlistId;
              }
            })
            .whereType<String>()
            .toList() +
        blacklistedPlaylist;

    if (res.code == 1) {
      final cloudpipedPlaylistsId = res.response
          .map((e) {
            return e['id'];
          })
          .whereType<String>()
          .toList();
      //add new playlist from cloud
      for (dynamic playlist in res.response) {
        if (!libPipedPlaylistsId.contains(playlist['id'])) {
          final plst = Playlist(
            title: playlist['name'],
            playlistId: playlist['id'],
            description: "Piped Playlist",
            thumbnailUrl: playlist['thumbnail'],
            isPipedPlaylist: true,
          );
          libraryPlaylists.add(plst);
        }
      }

      //remove playist if removed from cloud
      for (Playlist playlist in libraryPlaylists.toList()) {
        if (!cloudpipedPlaylistsId.contains(playlist.playlistId) &&
            playlist.isPipedPlaylist) {
          libraryPlaylists.removeWhere(
              (element) => element.playlistId == playlist.playlistId);
        }
      }
    }
    box.close();
  }

  Future<bool> renamePlaylist(Playlist playlist) async {
    String title = textInputController.text;
    if (title.trim().isNotEmpty) {
      if (playlist.isPipedPlaylist) {
        final res = await Get.find<PipedServices>()
            .renamePlaylist(playlist.playlistId, title);
        if (res.code == 0) return false;
        playlist.newTitle = title;
      } else {
        final box = await Hive.openBox("LibraryPlaylists");
        title = "${title[0].toUpperCase()}${title.substring(1).toLowerCase()}";
        playlist.newTitle = title;
        box.put(playlist.playlistId, playlist.toJson());
      }
      refreshLib();
      return true;
    }
    return false;
  }

  void changeCreationMode(String? val) {
    playlistCreationMode.value = val!;
  }

  Future<bool> createNewPlaylist(
      {bool createPlaylistNaddSong = false, List<MediaItem>? songItems}) async {
    String title = textInputController.text;
    if (title.trim().isNotEmpty) {
      dynamic newplst;

      if (playlistCreationMode.value == "piped") {
        creationInProgress.value = true;
        final res = await Get.find<PipedServices>().createPlaylist(title);
        if (res.code == 1) {
          newplst = Playlist(
              title: title,
              playlistId: "${res.response['playlistId']}",
              thumbnailUrl: songItems != null
                  ? songItems[0].artUri.toString()
                  : Playlist.thumbPlaceholderUrl,
              description: "Piped Playlist",
              isCloudPlaylist: true,
              isPipedPlaylist: true);
        } else {
          creationInProgress.value = false;
          return false;
        }
      } else {
        newplst = Playlist(
            title: title,
            playlistId: "LIB${DateTime.now().millisecondsSinceEpoch}",
            thumbnailUrl: songItems != null
                ? songItems[0].artUri.toString()
                : Playlist.thumbPlaceholderUrl,
            description: "Library Playlist",
            isCloudPlaylist: false);
        final box = await Hive.openBox("LibraryPlaylists");
        box.put(newplst.playlistId, newplst.toJson());
        await box.close();
      }

      libraryPlaylists.add(newplst);

      if (createPlaylistNaddSong && playlistCreationMode.value == "local") {
        final plastbox = await Hive.openBox(newplst.playlistId);
        for (MediaItem item in songItems!) {
          plastbox.add(MediaItemBuilder.toJson(item));
        }
        plastbox.close();
      } else if ((createPlaylistNaddSong &&
          playlistCreationMode.value == "piped")) {
        final songIds = songItems!.map((e) => e.id).toList();
        await Get.find<PipedServices>()
            .addToPlaylist(newplst.playlistId, songIds);
      }
      creationInProgress.value = false;
      return true;
    }
    return false;
  }

  Future<void> blacklistPipedPlaylist(Playlist playlist) async {
    final box = await Hive.openBox('blacklistedPlaylist');
    box.add(playlist.playlistId);
    libraryPlaylists.remove(playlist);
    box.close();
  }

  Future<void> resetBlacklistedPlaylist() async {
    final box = await Hive.openBox('blacklistedPlaylist');
    box.clear();
    syncPipedPlaylist();
  }

  void onSort(SortType sortType, bool isAscending) {
    final playlists = libraryPlaylists.toList();
    playlists.removeRange(0, 4);
    sortPlayLists(playlists, sortType, isAscending);
    playlists.insertAll(0, initPlst);
    libraryPlaylists.value = playlists;
  }

  void onSearchStart(String? tag) {
    tempListContainer = libraryPlaylists.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryPlaylists.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryPlaylists.value = tempListContainer.toList();
    tempListContainer.clear();
  }

  @override
  void dispose() {
    textInputController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> importPlaylistFromJson(BuildContext context) async {
    try {
      isImporting.value = true;
      importProgress.value = 0.1;

      // Show progress dialog
      if (context.mounted) {
        _showImportProgressDialog(context);
      }

      // Use file_picker to select JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'importPlaylist'.tr,
      );

      if (result == null || result.files.isEmpty) {
        // User cancelled the picker
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        isImporting.value = false;
        importProgress.value = 0.0;
        return;
      }

      importProgress.value = 0.2;

      final file = File(result.files.single.path!);
      if (!await file.exists()) {
        throw FileSystemException("fileNotFound".tr);
      }

      final jsonString = await file.readAsString();
      importProgress.value = 0.3;

      final jsonData = jsonDecode(jsonString);
      importProgress.value = 0.4;

      // Validate JSON structure
      if (!jsonData.containsKey('playlistInfo') ||
          !jsonData.containsKey('songs')) {
        throw FormatException("invalidPlaylistFile".tr);
      }

      // Create new playlist ID
      final playlistInfo = jsonData['playlistInfo'];
      final newPlaylistId = "LIB${DateTime.now().millisecondsSinceEpoch}";
      importProgress.value = 0.5;

      // Create playlist object
      final newPlaylist = Playlist(
        title: "${playlistInfo['title']} (${"imported".tr})",
        playlistId: newPlaylistId,
        thumbnailUrl: playlistInfo['thumbnailUrl'] ??
            (playlistInfo['thumbnails'] != null &&
                    playlistInfo['thumbnails'].isNotEmpty
                ? playlistInfo['thumbnails'][0]['url']
                : Playlist.thumbPlaceholderUrl),
        description: playlistInfo['description'] ?? "importedPlaylist".tr,
        isCloudPlaylist: false,
      );
      importProgress.value = 0.6;

      // Save playlist to database
      final box = await Hive.openBox("LibraryPlaylists");
      box.put(newPlaylistId, newPlaylist.toJson());
      importProgress.value = 0.7;

      // Save songs to playlist
      final songsBox = await Hive.openBox(newPlaylistId);
      final songsList = jsonData['songs'] as List;

      // Update progress as songs are added
      final totalSongs = songsList.length;
      for (int i = 0; i < totalSongs; i++) {
        await songsBox.put(i, songsList[i]);
        // Update progress from 70% to 95% based on song import progress
        importProgress.value = 0.7 + (0.25 * (i + 1) / totalSongs);
      }

      await songsBox.close();
      await box.close();
      importProgress.value = 1.0;

      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Refresh library to show the new playlist
      refreshLib();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          snackbar(
            context,
            "${"playlistImportedMsg".tr}: ${newPlaylist.title}",
            size: SanckBarSize.MEDIUM,
          ),
        );
      }
    } catch (e) {
      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      printERROR("Error importing playlist: $e");

      String errorMsg = "importError".tr;
      if (e is FileSystemException) {
        errorMsg = "importErrorFileAccess".tr;
      } else if (e is FormatException) {
        errorMsg = "importErrorFormat".tr;
      } else if (e.toString().contains("invalidPlaylistFile")) {
        errorMsg = "invalidPlaylistFile".tr;
      } else if (e is HiveError) {
        errorMsg = "importErrorDatabase".tr;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            snackbar(context, errorMsg, size: SanckBarSize.MEDIUM));
      }
    } finally {
      isImporting.value = false;
      importProgress.value = 0.0;
    }
  }

  // Helper method to show import progress dialog
  void _showImportProgressDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "importingPlaylist".tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: Get.isRegistered<LibraryPlaylistsController>()
                      ? importProgress.value
                      : 0,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${(Get.isRegistered<LibraryPlaylistsController>() ? importProgress.value * 100 : 0).toInt()}%",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )),
      ),
      barrierDismissible: false,
    );
  }
}

class LibraryAlbumsController extends GetxController {
  late RxList<Album> libraryAlbums = RxList();
  final isContentFetched = false.obs;
  List<Album> tempListContainer = [];

  @override
  void onInit() {
    refreshLib();
    super.onInit();
  }

  void refreshLib() async {
    final box = await Hive.openBox("LibraryAlbums");
    libraryAlbums.value = box.values
        .map<Album?>((item) => Album.fromJson(item))
        .whereType<Album>()
        .toList();

    isContentFetched.value = true;
    box.close();
  }

  void onSort(SortType sortType, bool isAscending) {
    final albumList = libraryAlbums.toList();
    sortAlbumNSingles(albumList, sortType, isAscending);
    libraryAlbums.value = albumList;
  }

  void onSearchStart(String? tag) {
    tempListContainer = libraryAlbums.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.title.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryAlbums.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryAlbums.value = tempListContainer.toList();
    tempListContainer.clear();
  }
}

class LibraryArtistsController extends GetxController {
  RxList<Artist> libraryArtists = RxList();
  final isContentFetched = false.obs;
  List<Artist> tempListContainer = [];

  @override
  void onInit() {
    refreshLib();
    super.onInit();
  }

  void refreshLib() async {
    final box = await Hive.openBox("LibraryArtists");
    libraryArtists.value = box.values
        .map<Artist?>((item) => Artist.fromJson(item))
        .whereType<Artist>()
        .toList();
    isContentFetched.value = true;
    box.close();
  }

  void onSort(SortType sortType, bool isAscending) {
    final artistList = libraryArtists.toList();
    sortArtist(artistList, sortType, isAscending);
    libraryArtists.value = artistList;
  }

  void onSearchStart(String? tag) {
    tempListContainer = libraryArtists.toList();
  }

  void onSearch(String value, String? tag) {
    final songlist = tempListContainer
        .where((element) =>
            element.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    libraryArtists.value = songlist;
  }

  void onSearchClose(String? tag) {
    libraryArtists.value = tempListContainer.toList();
    tempListContainer.clear();
  }
}
