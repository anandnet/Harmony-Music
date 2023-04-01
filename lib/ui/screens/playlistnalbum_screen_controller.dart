import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import '../../services/music_service.dart';

class PlayListNAlbumScreenController extends GetxController {
  PlayListNAlbumScreenController(dynamic content, bool isAlbum) {
    this.isAlbum.value = isAlbum;
    _fetchSong(isAlbum ? content.browseId : content.playlistId);
  }
  final MusicServices _musicServices = Get.find<MusicServices>();
  late RxList<MediaItem> songList = RxList();
  final isContentFetched = false.obs;
  final isAlbum = false.obs;

  Future<void> _fetchSong(String id) async {
    isContentFetched.value = false;
    final content = isAlbum.isTrue
        ? await _musicServices.getPlaylistOrAlbumSongs(albumId: id)
        : await _musicServices.getPlaylistOrAlbumSongs(playlistId: id);
    songList.value =List<MediaItem>.from(content['tracks']);
    isContentFetched.value = true;
  }
}
