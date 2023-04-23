import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../services/music_service.dart';
import '../utils/home_library_controller.dart';

class PlayListNAlbumScreenController extends GetxController {
  PlayListNAlbumScreenController(dynamic content, bool isAlbum) {
    this.isAlbum.value = isAlbum;
    final id = isAlbum ? content.browseId : content.playlistId;
    if(!isAlbum && !content.isCloudPlaylist){
      if(content.playlistId == 'LIBCAC'){
        songList.value = Get.find<LibrarySongsController>().cachedSongsList;
        isContentFetched.value=true;
      }
        return;
    }
    _checkIfAddedToLibrary(id);
    _fetchSong(id);
  }
  final MusicServices _musicServices = Get.find<MusicServices>();
  late RxList<MediaItem> songList = RxList();
  final isContentFetched = false.obs;
  final isAlbum = false.obs;
  final isAddedToLibrary = false.obs;

  Future<void> _checkIfAddedToLibrary(String id) async {
    //check
    final box = isAlbum.isTrue
        ? await Hive.openBox("LibraryAlbums")
        : await Hive.openBox("LibraryPlaylists");
    isAddedToLibrary.value = box.containsKey(id);
    await box.close();
  }

  Future<void> _fetchSong(String id) async {
    isContentFetched.value = false;

    final content = isAlbum.isTrue
        ? await _musicServices.getPlaylistOrAlbumSongs(albumId: id)
        : await _musicServices.getPlaylistOrAlbumSongs(playlistId: id);
    songList.value = List<MediaItem>.from(content['tracks']);
    isContentFetched.value = true;
  }

  Future<void> addNremoveFromLibrary(dynamic content, {bool add = true}) async {
    try {
      final box = isAlbum.isTrue
          ? await Hive.openBox("LibraryAlbums")
          : await Hive.openBox("LibraryPlaylists");
      final id = isAlbum.isTrue ? content.browseId : content.playlistId;
      add ? box.put(id, content.toJson()) : box.delete(id);
      isAddedToLibrary.value = add;
      //Update frontend
     isAlbum.isTrue? Get.find<LibraryAlbumsController>().refreshLib()
          : Get.find<LibraryPlaylistsController>().refreshLib();
      Get.snackbar("Info", add ? "Added to Library" : "Removed from Library",
          duration: const Duration(milliseconds: 1250),
          animationDuration: const Duration(microseconds: 700),colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Info", "Operation Failed",
          duration: const Duration(milliseconds: 1250),
          animationDuration: const Duration(seconds: 1));
    }
  }
}
