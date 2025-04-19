import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/album.dart';
import '../models/media_Item_builder.dart';
import '../models/playlist.dart';
import '../services/music_service.dart';
import '../ui/widgets/sort_widget.dart';

/// An abstract base class for managing playlist and album screens in the application.
/// This class provides a set of methods and properties to handle various operations
/// such as fetching album/playlist details, managing songs, and performing additional operations.
abstract class PlaylistAlbumScreenControllerBase extends GetxController {
  /// Instance of [MusicServices] used to interact with music-related services.
  final MusicServices musicServices = Get.find<MusicServices>();

  /// Observable boolean indicating whether the album is offline.
  final RxBool isOffline = false.obs;

  /// Observable list of songs represented as [MediaItem].
  final RxList<MediaItem> songList = <MediaItem>[].obs;

  /// Observable boolean indicating whether the content has been fetched.
  final RxBool isContentFetched = false.obs;

  /// Observable boolean indicating whether the album/playlist is added to the library.
  final RxBool isAddedToLibrary = false.obs;

  /// Observable double representing the scroll offset.
  final RxDouble scrollOffset = 0.0.obs;

  /// Observable boolean indicating whether the app bar title is visible.
  final RxBool appBarTitleVisible = false.obs;

  /// Observable boolean indicating whether the album/playlist is downloaded.
  final RxBool isDownloaded = false.obs;

  /// Checks if the album/playlist is added to the library.
  ///
  /// [id] - The unique identifier of the album/playlist.
  ///
  /// Returns a [Future] that resolves to `true` if added to the library, otherwise `false`.
  @protected
  Future<bool> checkIfAddedToLibrary(String id);

  /// Fetches the details of an album.
  ///
  /// [albumId] - The unique identifier of the album.
  @protected
  void fetchAlbumDetails(Album? album_, String albumId);

  /// Fetches the details of a playlist.
  ///
  /// [playlistId] - The unique identifier of the playlist.
  @protected
  void fetchPlaylistDetails(Playlist? playlist_, String playlistId);

  /// Fetches the songs of an album/playlist from database.
  ///
  /// [id] - The unique identifier of the album/playlist.
  void fetchSongsfromDatabase(String id) async {
    final box = await Hive.openBox(id);
    songList.value = box.values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList();
    if (id != "SongDownloads") await box.close();
    songList.value =
        id == "LIBRP" ? songList.reversed.toList() : songList.toList();
    checkDownloadStatus();
  }

  /// Checks the download status of the album/playlist.
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

  /// Adds or removes content from the library.
  ///
  /// [content] - The content to be added or removed.
  /// [add] - A boolean indicating whether to add (`true`) or remove (`false`) the content.
  ///
  /// Returns a [Future] that resolves to `true` if the operation is successful, otherwise `false`.
  ///
  /// This method is only applicable for playlists.
  @protected
  Future<bool> addNremoveFromLibrary(dynamic content, {bool add = true});

  /// Synchronizes the playlist songs.
  ///
  /// only applicable for playlist.
  @protected
  void syncPlaylistSongs();

  /// Updates the songs into the database.
  ///
  /// Only applicable for playlist.
  @protected
  Future<void> updateSongsIntoDb();

  /// Deletes multiple songs from the playlist.
  ///
  /// [songs] - A list of [MediaItem] representing the songs to be deleted.
  ///
  /// Valid only if the playlist is not a cloud playlist.
  Future<void> deleteMultipleSongs(List<MediaItem> songs);

  /// Retrieves the list of selected songs.
  ///
  /// Returns a list of [MediaItem] representing the selected songs.
  @protected
  List<MediaItem> selectedSongs();

  /// Handles the search operation.
  ///
  /// [value] - The search query.
  /// [tag] - An optional tag to identify the search context.
  void onSearch(String value, String? tag);

  /// Handles the closing of the search operation.
  ///
  /// [tag] - An optional tag to identify the search context.
  void onSearchClose(String? tag);

  /// Handles the start of the search operation.
  ///
  /// [tag] - An optional tag to identify the search context.
  void onSearchStart(String? tag);

  /// Starts an additional operation based on the provided [SortWidgetController] and [OperationMode].
  ///
  /// [sortWidgetController_] - The controller for the sort widget.
  /// [mode] - The mode of the operation.
  void startAdditionalOperation(
      SortWidgetController sortWidgetController_, OperationMode mode);

  /// Selects or deselects all items.
  ///
  /// [selectAll] - A boolean indicating whether to select all (`true`) or deselect all (`false`).
  void selectAll(bool selectAll);

  /// Performs an additional operation.
  void performAdditionalOperation();

  /// Cancels the additional operation.
  void cancelAdditionalOperation();
}
