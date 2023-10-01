import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '/services/piped_service.dart';
import '../../utils/helper.dart';
import '/models/playlist.dart';
import '/models/album.dart';
import '/models/thumbnail.dart';
import '../../models/media_Item_builder.dart';
import '../../services/music_service.dart';
import '../utils/home_library_controller.dart';

class PlayListNAlbumScreenController extends GetxController {
  final MusicServices _musicServices = Get.find<MusicServices>();
  late RxList<MediaItem> songList = RxList();
  final isContentFetched = false.obs;
  final isAddedToLibrary = false.obs;
  final isSearchingOn = false.obs;
  late final String id;
  late dynamic contentRenderer;
  late bool isAlbum;
  List<MediaItem> tempListContainer = [];
  dynamic box;

  @override
  void onReady() {
    final args = Get.arguments;
    if(args!=null){
      isAlbum = args[0];
      _init(args[1], args[0], args[2]);
    }
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

    _checkIfAddedToLibrary(id);
    _fetchSong(id, isIdOnly, isPipedPlaylist);
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
      index != null ? songList.insert(index, item!) : songList.add(item!);
    } else {
      index != null ? songList.removeAt(index) : songList.remove(item);
    }
  }

  Future<void> fetchSongsfromDatabase(id) async {
    box = await Hive.openBox(id);
    songList.value = box.values
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList()
        .reversed
        .toList();
    isContentFetched.value = true;
  }

  Future<void> _fetchSong(
      String id, bool isIdOnly, bool isPipedPlaylist) async {
    isContentFetched.value = false;

    if (isPipedPlaylist) {
      songList.value = (await Get.find<PipedServices>().getPlaylistSongs(id));
      isContentFetched.value = true;
      return;
    }

    final content = isAlbum
        ? await _musicServices.getPlaylistOrAlbumSongs(albumId: id)
        : await _musicServices.getPlaylistOrAlbumSongs(playlistId: id);

    if (isIdOnly) {
      if (isAlbum) {
        final album = Album(
            browseId: id,
            artists: List<Map<dynamic, dynamic>>.from(content['artists']),
            thumbnailUrl: Thumbnail(content['thumbnails'][0]['url']).high,
            title: content['title'],
            audioPlaylistId: content['audioPlaylistId'],
            year: content['year']);
        contentRenderer = album;
      } else {
        final playlist = Playlist(
            title: content['title'],
            playlistId: id,
            thumbnailUrl: Thumbnail(content['thumbnails'][0]['url']).high,
            description: content['description'],
            isCloudPlaylist: true,
            songCount: (content['trackCount']).toString());
        contentRenderer = playlist;
      }
    }
    songList.value = List<MediaItem>.from(content['tracks']);
    isContentFetched.value = true;
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
        add ? box.put(id, content.toJson()) : box.delete(id);
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

  void onSort(bool sortByName, bool sortByDuration, bool isAscending) {
    final songlist_ = songList.toList();
    sortSongsNVideos(songlist_, sortByName, false, sortByDuration, isAscending);
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


  @override
  void onClose() {
    tempListContainer.clear();
    box.close();
    super.onClose();
  }
}
