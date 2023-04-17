import 'package:audio_service/audio_service.dart';
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
  late RxList<Playlist> libraryPlaylists = RxList();
  final isContentFetched = false.obs;

  @override
  void onInit() {
    refreshLib();
    super.onInit();
  }

  void refreshLib() async {
    final box = await Hive.openBox("LibraryPlaylists");
    libraryPlaylists.value = box.values
        .map<Playlist?>((item) => Playlist.fromJson(item))
        .whereType<Playlist>()
        .toList();
    isContentFetched.value = true;
    await box.close();
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
