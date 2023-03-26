import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/media_Item_builder.dart';
import '../../services/music_service.dart';

class PlayListScreenController extends GetxController {
  PlayListScreenController(String playlistId) {
    _fetchPlaylistSong(playlistId);
  }
  final MusicServices _musicServices = Get.find<MusicServices>();
  late RxList<MediaItem> songList = RxList();
  final isContentFetched = false.obs;

  Future<void> _fetchPlaylistSong(String playlistId) async {
    isContentFetched.value = false;
    final playlistContent = await _musicServices.getPlaylistSongs(playlistId);
    songList.value = (playlistContent['tracks'])
        .map<MediaItem?>((item) => MediaItemBuilder.fromJson(item))
        .whereType<MediaItem>()
        .toList();
    isContentFetched.value = true;

    
  }
}
