import 'package:audio_service/audio_service.dart' show MediaItem;
import 'package:get/get.dart';
import 'package:harmonymusic/models/thumbnail.dart';
import 'package:harmonymusic/utils/helper.dart';
import 'package:hive/hive.dart';

import '../../../base_class/playlist_album_screen_con_base.dart';
import '../../../mixins/additional_opeartion_mixin.dart';
import '../../../models/media_Item_builder.dart';
import '../../../models/playlist.dart';
import '../../../services/music_service.dart';
import '../../../services/piped_service.dart';
import '../Library/library_controller.dart';

///PlaylistScreenController handles playlist screen
///
///Playlist title,image,songs
class PlaylistScreenController extends PlaylistAlbumScreenControllerBase
    with AdditionalOpeartionMixin {
  final MusicServices _musicServices = Get.find<MusicServices>();
  final playlist = Playlist(
    title: "",
    playlistId: "",
    thumbnailUrl: Playlist.thumbPlaceholderUrl,
  ).obs;
  final isDefaultPlaylist = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as List;
    final Playlist? playlist = args[0];
    final playlistId = args[1];
    fetchPlaylistDetails(playlist, playlistId);
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

      fetchSongsfromDatabase(playlistId);
      isContentFetched.value = true;

      Future.delayed(
          const Duration(seconds: 1), () => _updatePlaylistThumbSongBased());

      return;
    }

    if (!isIdOnly) {
      playlist.value = playlist_;
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
  void fetchAlbumDetails(String albumId) {} // Not used in this class

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

    super.onClose();
  }
}
