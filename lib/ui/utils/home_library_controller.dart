import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/artist.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:hive/hive.dart';

class LibrarySongsController extends GetxController {
  late RxList<MediaItem> cachedSongsList = RxList();
  final isSongFetched = false.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() {
    final box = Hive.box("SongsCache");
    cachedSongsList.value = box.values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList();
    isSongFetched.value = true;
  }
}

class LibraryPlaylistsController extends GetxController {
  final initPlst = [
    Playlist(
        title: "Recently Played",
        playlistId: "LIBRP",
        thumbnailUrl: "",
        isCloudPlaylist: false),
    Playlist(
        title: "Favourite",
        playlistId: "LIBFAV",
        thumbnailUrl: "",
        isCloudPlaylist: false),
    Playlist(
        title: "Cached/Offline",
        playlistId: "SongsCache",
        thumbnailUrl: "",
        isCloudPlaylist: false)
  ];
  late RxList<Playlist> libraryPlaylists = RxList(initPlst);
  final isContentFetched = false.obs;
  final textInputController = TextEditingController();

  @override
  void onInit() {
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
    isContentFetched.value = true;
    await box.close();
  }

  Future<bool> renamePlaylist(Playlist playlist) async {
    String title = textInputController.text;
    if (title != "") {
      final box = await Hive.openBox("LibraryPlaylists");
      title = "${title[0].toUpperCase()}${title.substring(1).toLowerCase()}";
      playlist.newTitle = title;
      box.put(playlist.playlistId, playlist.toJson());
      refreshLib();
      return true;
    }
    return false;
  }

  Future<bool> createNewPlaylist(
      {bool createPlaylistNaddSong = false, MediaItem? songItem}) async {
    String title = textInputController.text;
    if (title != "") {
      title = "${title[0].toUpperCase()}${title.substring(1).toLowerCase()}";
      final newplst = Playlist(
          title: title,
          playlistId: "LIB${DateTime.now().millisecondsSinceEpoch}",
          thumbnailUrl: "",
          description: "Library Playlist",
          isCloudPlaylist: false);
      final box = await Hive.openBox("LibraryPlaylists");
      box.put(newplst.playlistId, newplst.toJson());
      libraryPlaylists.add(newplst);
      if (createPlaylistNaddSong) {
        final plastbox = await Hive.openBox(newplst.playlistId);
        plastbox.put(songItem?.id, MediaItemBuilder.toJson(songItem!));
        plastbox.close();
      }
      await box.close();
      return true;
    }
    return false;
  }
}

class LibraryAlbumsController extends GetxController {
  late RxList<Album> libraryAlbums = RxList();
  final isContentFetched = false.obs;

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
}

class LibraryArtistsController extends GetxController {
  RxList<Artist> libraryArtists = RxList();
  final isContentFetched = false.obs;

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
}
