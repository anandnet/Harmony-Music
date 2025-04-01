import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:get/get.dart';
import 'package:harmonymusic/base_class/playlist_album_screen_con_base.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

import '../../../mixins/additional_opeartion_mixin.dart';
import '../../../models/media_Item_builder.dart';
import '../Library/library_controller.dart';

///AlbumScreenController handles album screen
///
///Album title,image,songs
class AlbumScreenController extends PlaylistAlbumScreenControllerBase
    with AdditionalOpeartionMixin {
  final album =
      Album(title: "", browseId: "", thumbnailUrl: "", artists: []).obs;
  final isOfflineAlbum = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as String;
    final albumId = args;
    fetchAlbumDetails(albumId);
  }

  ///Fetches album details from the service
  @override
  void fetchAlbumDetails(String albumId) async {
    try {
      // Check if the album is offline
      if (!await checkIfAddedToLibrary(albumId)) {
        // Fetch album details online
        final content =
            await musicServices.getPlaylistOrAlbumSongs(albumId: albumId);
        content['browseId'] = albumId;
        album.value = Album.fromJson(content);
        songList.value = List<MediaItem>.from(content['tracks']);
      } else {
        // If the album is offline, fetch the songs from the local database
        // Album details are already fetched in _checkIfAddedToLibrary method
        final box = await Hive.openBox(albumId);
        songList.value = box.values
            .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
            .whereType<MediaItem>()
            .toList();
        box.close();
      }
      checkDownloadStatus();
      isContentFetched.value = true;
    } catch (e) {
      // Handle any errors that occur during the fetch
      printERROR("Error fetching album details: $e");
    }
  }

  @override
  Future<bool> checkIfAddedToLibrary(String id) async {
    final box = await Hive.openBox("LibraryAlbums");
    isAddedToLibrary.value = box.containsKey(id);
    if (isAddedToLibrary.value) album.value = Album.fromJson(box.get(id));
    box.close();
    return isAddedToLibrary.value;
  }

  @override
  Future<bool> addNremoveFromLibrary(content, {bool add = true}) async {
    try {
      final box = await Hive.openBox("LibraryAlbums");
      final id = content.browseId;
      if (add) {
        box.put(id, content.toJson());
        updateSongsIntoDb();
      } else {
        box.delete(id);
        final songsBox = await Hive.openBox(id);
        songsBox.deleteFromDisk();
      }
      isAddedToLibrary.value = add;

      //Update frontend
      Get.find<LibraryAlbumsController>().refreshLib();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateSongsIntoDb() async {
    final songsBox = await Hive.openBox(album.value.browseId);
    await songsBox.clear();
    final songListCopy = songList.toList();
    for (int i = 0; i < songListCopy.length; i++) {
      await songsBox.put(i, MediaItemBuilder.toJson(songListCopy[i]));
    }
     await songsBox.close();
  }

  @override
  void onClose() {
    tempListContainer.clear();
    super.onClose();
  }

  @override
  Future<void> deleteMultipleSongs(List<MediaItem> songs) async {}

  @override
  void fetchPlaylistDetails(Playlist? playlist_, String playlistId) {}

  @override
  void syncPlaylistSongs() {}
}
