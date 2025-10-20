import 'dart:convert';
import 'dart:io';
import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/thumbnail.dart';
import 'package:harmonymusic/services/permission_service.dart';
import 'package:harmonymusic/ui/screens/Settings/settings_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/snackbar.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../../base_class/playlist_album_screen_con_base.dart';
import '../../../mixins/additional_opeartion_mixin.dart';
import '../../../models/album.dart' show Album;
import '../../../models/media_Item_builder.dart';
import '../../../models/playlist.dart';
import '../../../services/music_service.dart';
import '../../../services/piped_service.dart';
import '../Home/home_screen_controller.dart';
import '../Library/library_controller.dart';

///PlaylistScreenController handles playlist screen
///
///Playlist title,image,songs
class PlaylistScreenController extends PlaylistAlbumScreenControllerBase
    with AdditionalOpeartionMixin, GetSingleTickerProviderStateMixin {
  final MusicServices _musicServices = Get.find<MusicServices>();
  final playlist = Playlist(
    title: "",
    playlistId: "",
    thumbnailUrl: Playlist.thumbPlaceholderUrl,
  ).obs;
  final isDefaultPlaylist = false.obs;

  // Add this RxBool to track export progress
  final isExporting = false.obs;
  final exportProgress = 0.0.obs;

  String generatedYtmPlaylistUrl = '';

  // Title animation

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heightAnimation;

  AnimationController get animationController => _animationController;
  Animation<double> get scaleAnimation => _scaleAnimation;
  Animation<double> get heightAnimation => _heightAnimation;
  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation =
        Tween<double>(begin: 0, end: 1.0).animate(animationController);

    _heightAnimation =
        Tween<double>(begin: 10.0, end: 75.0).animate(CurvedAnimation(parent: animationController, curve: Curves.easeOutBack));

    final args = Get.arguments as List;
    final Playlist? playlist = args[0];
    final playlistId = args[1];
    fetchPlaylistDetails(playlist, playlistId);
    Future.delayed(const Duration(milliseconds: 200),
        () => Get.find<HomeScreenController>().whenHomeScreenOnTop());
  }

  ///Fetches playlist details from the service
  @override
  void fetchPlaylistDetails(Playlist? playlist_, String playlistId) async {
    final isIdOnly = playlist_ == null;
    final isPipedPlaylist = playlist_?.isPipedPlaylist ?? false;
    isDefaultPlaylist.value = (playlistId == "SongDownloads" ||
        playlistId == "SongsCache" ||
        playlistId == "LIBRP" ||
        playlistId == "LIBFAV");

    if (!isIdOnly && !playlist_.isCloudPlaylist) {
      playlist.value = playlist_;
      _animationController.forward();
      fetchSongsfromDatabase(playlistId);
      isContentFetched.value = true;

      Future.delayed(
          const Duration(seconds: 1), () => _updatePlaylistThumbSongBased());

      return;
    }

    if (!isIdOnly) {
      playlist.value = playlist_;
      _animationController.forward();
    }

    try {
      // Check if the playlist is offline
      if (await checkIfAddedToLibrary(playlistId)) {
        final songsBox = await Hive.openBox(playlistId);
        if (songsBox.values.isEmpty) {
          _fetchSongOnline(playlistId, isIdOnly, isPipedPlaylist).then((value) {
            updateSongsIntoDb();
          });
        } else {
          // If the playlist is offline, fetch the songs from the local database
          // Playlist details are already fetched in _checkIfAddedToLibrary method
          fetchSongsfromDatabase(playlistId);
        }
      } else {
        _fetchSongOnline(playlistId, isIdOnly, isPipedPlaylist);
      }
      isContentFetched.value = true;
    } catch (e) {
      // Handle any errors that occur during the fetch
      printERROR("Error fetching playlist details: $e");
    }
  }

  Future<void> _fetchSongOnline(
      String id, bool isIdOnly, bool isPipedPlaylist) async {
    isContentFetched.value = false;

    if (isPipedPlaylist) {
      songList.value = (await Get.find<PipedServices>().getPlaylistSongs(id));
      isContentFetched.value = true;
      checkDownloadStatus();
      return;
    }

    final content =
        await _musicServices.getPlaylistOrAlbumSongs(playlistId: id);

    if (isIdOnly) {
      content['playlistId'] = id;
      playlist.value = Playlist.fromJson(content);
      _animationController.forward();
    }
    songList.value = List<MediaItem>.from(content['tracks']);
    checkDownloadStatus();
  }

  @override
  void syncPlaylistSongs() {
    _fetchSongOnline(playlist.value.playlistId, false, false).then((value) {
      updateSongsIntoDb();
      isContentFetched.value = true;
    });
  }

  @override
  Future<bool> checkIfAddedToLibrary(String id) async {
    final box = await Hive.openBox("LibraryPlaylists");
    isAddedToLibrary.value = box.containsKey(id);
    if (isAddedToLibrary.value) playlist.value = Playlist.fromJson(box.get(id));
    await box.close();
    return isAddedToLibrary.value;
  }

  @override
  Future<bool> addNremoveFromLibrary(dynamic content, {bool add = true}) async {
    try {
      if (content.isPipedPlaylist && !add) {
        //remove piped playlist from lib
        final res =
            await Get.find<PipedServices>().deletePlaylist(content.playlistId);
        Get.find<LibraryPlaylistsController>().syncPipedPlaylist();
        return (res.code == 1);
      } else {
        final box = await Hive.openBox("LibraryPlaylists");
        final id = content.playlistId;
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
      Get.find<LibraryPlaylistsController>().refreshLib();
      if (!content.isCloudPlaylist && !add) {
        final plstbox = await Hive.openBox(content.playlistId);
        plstbox.deleteFromDisk();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateSongsIntoDb() async {
    final songsBox = await Hive.openBox(playlist.value.playlistId);
    await songsBox.clear();
    final songListCopy = songList.toList();
    for (int i = 0; i < songListCopy.length; i++) {
      await songsBox.put(i, MediaItemBuilder.toJson(songListCopy[i]));
    }
    if (playlist.value.playlistId != "SongDownloads") await songsBox.close();

    // Update the playlist thumbnail based on the first song's thumbnail
    _updatePlaylistThumbSongBased();
  }

  @override
  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {
    final id = playlist.value.playlistId;
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

    // Update the playlist thumbnail based on the first song's thumbnail
    _updatePlaylistThumbSongBased();
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

    // update the playlist thumbnail based on the first song's thumbnail
    _updatePlaylistThumbSongBased();
  }

  @override
  void fetchAlbumDetails(Album? album_,String albumId) {} // Not used in this class

  /// This function updates the local playlist thumbnail based on the first song's thumbnail
  void _updatePlaylistThumbSongBased() {
    final currentPlaylist = playlist.value;

    if (isDefaultPlaylist.isTrue || currentPlaylist.isCloudPlaylist) {
      return;
    }

    Playlist updatedplaylist;
    if (songList.isNotEmpty) {
      updatedplaylist =
          currentPlaylist.copyWith(thumbnailUrl: songList[0].artUri.toString());
    } else {
      updatedplaylist =
          currentPlaylist.copyWith(thumbnailUrl: Playlist.thumbPlaceholderUrl);
    }

    // Check if the thumbnail URL is the same as the current one
    // If it is, no need to update the playlist
    if (Thumbnail(currentPlaylist.thumbnailUrl).extraHigh ==
        Thumbnail(updatedplaylist.thumbnailUrl).extraHigh) {
      return;
    }

    // Update the playlist thumbnail URL
    playlist.value = updatedplaylist;
    Get.find<LibraryPlaylistsController>()
        .updatePlaylistIntoDb(updatedplaylist);
  }

  @override
  void onClose() {
    tempListContainer.clear();
    _animationController.dispose();
    Get.find<HomeScreenController>().whenHomeScreenOnTop();
    super.onClose();
  }

  Future<void> exportPlaylistToJson(BuildContext context) async {
    if (!await PermissionService.getExtStoragePermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(
            context, "permissionDenied".tr,
            size: SanckBarSize.MEDIUM));
      }
      return;
    }

    try {
      isExporting.value = true;
      exportProgress.value = 0.1;

      // Show progress dialog
      if (context.mounted) {
        _showProgressDialog(context, "exportingPlaylist".tr);
      }

      // Get appropriate directory based on platform
      final Directory exportDir = await _getExportDirectory();
      exportProgress.value = 0.2;

      // Create playlist data map
      final playlistData = {
        "playlistInfo": playlist.value.toJson(),
        "songs": songList.map((song) => MediaItemBuilder.toJson(song)).toList(),
        "exportDate": DateTime.now().toIso8601String(),
        "appVersion": Get.find<SettingsScreenController>().currentVersion,
      };
      exportProgress.value = 0.5;

      // Generate filename with playlist name
      final sanitizedName =
          playlist.value.title.replaceAll(RegExp(r'[^\w\s]+'), '_');

      // Find available filename with incremental suffix if needed
      String filename = "$sanitizedName.json";
      String filePath = "${exportDir.path}/$filename";
      File file = File(filePath);

      int counter = 1;
      while (await file.exists()) {
        filename = "${sanitizedName}_$counter.json";
        filePath = "${exportDir.path}/$filename";
        file = File(filePath);
        counter++;
      }

      exportProgress.value = 0.7;

      // Write JSON to file
      await file.writeAsString(jsonEncode(playlistData));
      exportProgress.value = 1.0;

      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show success message with platform-specific path info
      String locationMsg = _getLocationMessage(exportDir.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(
            context, "${"playlistExportedMsg".tr}: $locationMsg",
            size: SanckBarSize.MEDIUM));
      }
    } catch (e) {
      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      printERROR("Error exporting playlist: $e");
      
      String errorMsg = "exportError".tr;
      if (e is FileSystemException) {
        if (e.osError?.errorCode == 13) {
          errorMsg = "exportErrorPermission".tr;
        } else if (e.osError?.errorCode == 28) {
          errorMsg = "exportErrorStorage".tr;
        }
      } else if (e is FormatException) {
        errorMsg = "exportErrorFormat".tr;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            snackbar(context, errorMsg, size: SanckBarSize.MEDIUM));
      }
    } finally {
      isExporting.value = false;
      exportProgress.value = 0.0;
    }
  }

  Future<void> exportPlaylistToCsv(BuildContext context) async {
    if (!await PermissionService.getExtStoragePermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(
            context, "permissionDenied".tr,
            size: SanckBarSize.MEDIUM));
      }
      return;
    }

    try {
      isExporting.value = true;
      exportProgress.value = 0.1;

      // Show progress dialog
      if (context.mounted) {
        _showProgressDialog(context, "exportingPlaylist".tr);
      }

      // Get appropriate directory based on platform
      final Directory exportDir = await _getExportDirectory();
      exportProgress.value = 0.2;

      // Build CSV content
      final csvContent = _generateCsvContent();
      exportProgress.value = 0.5;

      // Generate filename with playlist name
      final sanitizedName =
          playlist.value.title.replaceAll(RegExp(r'[^\w\s]+'), '_');

      // Find available filename with incremental suffix if needed
      String filename = "$sanitizedName.csv";
      String filePath = "${exportDir.path}/$filename";
      File file = File(filePath);

      int counter = 1;
      while (await file.exists()) {
        filename = "${sanitizedName}_$counter.csv";
        filePath = "${exportDir.path}/$filename";
        file = File(filePath);
        counter++;
      }

      exportProgress.value = 0.7;

      // Write CSV to file
      await file.writeAsString(csvContent);
      exportProgress.value = 1.0;

      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Show success message with platform-specific path info
      String locationMsg = _getLocationMessage(exportDir.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackbar(
            context, "${"playlistExportedMsg".tr}: $locationMsg",
            size: SanckBarSize.MEDIUM));
      }
    } catch (e) {
      // Close progress dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      printERROR("Error exporting playlist to CSV: $e");
      
      String errorMsg = "exportError".tr;
      if (e is FileSystemException) {
        if (e.osError?.errorCode == 13) {
          errorMsg = "exportErrorPermission".tr;
        } else if (e.osError?.errorCode == 28) {
          errorMsg = "exportErrorStorage".tr;
        }
      } else if (e is FormatException) {
        errorMsg = "exportErrorFormat".tr;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            snackbar(context, errorMsg, size: SanckBarSize.MEDIUM));
      }
    } finally {
      isExporting.value = false;
      exportProgress.value = 0.0;
    }
  }

  String _generateCsvContent() {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('PlaylistBrowseId,PlaylistName,MediaId,Title,Artists,Duration,ThumbnailUrl,AlbumId,AlbumTitle,ArtistIds');
    
    // CSV Rows - one for each song
    for (final song in songList) {
      // Keep playlistBrowseId blank for offline/piped playlists
      final playlistBrowseId = (!playlist.value.isCloudPlaylist || playlist.value.isPipedPlaylist)
          ? ''
          : _escapeCsvField(playlist.value.playlistId);
      final playlistName = _escapeCsvField(playlist.value.title);
      final mediaId = _escapeCsvField(song.id);
      final title = _escapeCsvField(song.title);
      
      // Extract artists as comma-separated string
      final artistsList = song.extras?['artists'] as List?;
      final artists = artistsList != null
          ? _escapeCsvField(artistsList.map((a) => a['name']).join(', '))
          : '';
      
      // Format duration as HH:MM:SS or MM:SS
      final duration = song.duration != null
          ? _formatDuration(song.duration!)
          : '';
      
      final thumbnailUrl = _escapeCsvField(song.artUri.toString());
      
      // Extract album information
      final albumData = song.extras?['album'] as Map?;
      final albumId = albumData != null ? _escapeCsvField(albumData['id'] ?? '') : '';
      final albumTitle = albumData != null ? _escapeCsvField(albumData['name'] ?? '') : '';
      
      // Extract all artist IDs (comma-separated)
      final artistIds = artistsList != null && artistsList.isNotEmpty
          ? _escapeCsvField(artistsList.map((a) => a['id'] ?? '').join(','))
          : '';
      
      buffer.writeln('$playlistBrowseId,$playlistName,$mediaId,$title,$artists,$duration,$thumbnailUrl,$albumId,$albumTitle,$artistIds');
    }
    
    return buffer.toString();
  }

  String _escapeCsvField(String field) {
    // Escape double quotes by doubling them
    String escaped = field.replaceAll('"', '""');
    
    // If field contains comma, newline, or double quote, wrap in quotes
    if (escaped.contains(',') || escaped.contains('\n') || escaped.contains('"')) {
      escaped = '"$escaped"';
    }
    
    return escaped;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Helper method to get the appropriate export directory for each platform
  Future<Directory> _getExportDirectory() async {
    Directory directory;
    const appFolderName = "HarmonyMusic";

    try {
      if (Platform.isAndroid) {
        // Android: use Downloads folder
        directory = Directory('/storage/emulated/0/Download/$appFolderName');
      } else if (Platform.isIOS) {
        // iOS: use Documents directory
        final docDir = await path_provider.getApplicationDocumentsDirectory();
        directory = Directory('${docDir.path}/$appFolderName');
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop platforms: use Downloads folder in user's home directory
        final homeDir = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            '.';
        directory = Directory('$homeDir/Downloads/$appFolderName');
      } else {
        // Fallback: use temporary directory
        final tempDir = await path_provider.getTemporaryDirectory();
        directory = Directory('${tempDir.path}/$appFolderName');
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      return directory;
    } catch (e) {
      // Fallback to app's documents directory if any error occurs
      final appDocDir = await path_provider.getApplicationDocumentsDirectory();
      directory = Directory('${appDocDir.path}/$appFolderName');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    }
  }

  // Helper method to get a user-friendly location message
  String _getLocationMessage(String path) {
    if (Platform.isAndroid) {
      return "Downloads/HarmonyMusic";
    } else if (Platform.isIOS) {
      return "Files App > HarmonyMusic";
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return "Downloads/HarmonyMusic";
    } else {
      return path.split('/').last;
    }
  }

  // Helper method to show progress dialog
  void _showProgressDialog(BuildContext context, String title) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: exportProgress.value,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${(exportProgress.value * 100).toInt()}%",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )),
      ),
      barrierDismissible: false,
    );
  }
}
