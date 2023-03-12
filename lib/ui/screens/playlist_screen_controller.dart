import 'package:get/get.dart';

import '../../models/song.dart';
import '../../services/music_service.dart';

class PlayListScreenController extends GetxController{
  PlayListScreenController(String playlistId){
    _fetchPlaylistSong(playlistId);
  }
  late RxList<Song> songList = RxList();
  final isContentFetched = false.obs;
  
  Future<void> _fetchPlaylistSong(String playlistId) async {
    isContentFetched.value= false;
    final playlistContent= await MusicServices().getPlaylistSongs(playlistId);
    songList.value = (playlistContent['tracks']).map<Song?>((song)=>Song.fromJson(song)).whereType<Song>().toList();
    isContentFetched.value =true;
  }

}