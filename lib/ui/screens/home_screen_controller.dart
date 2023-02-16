import 'dart:developer';

import 'package:get/get.dart';
import 'package:harmonymusic/models/song.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/song_stream_url_service.dart';

class HomeScreenController extends GetxController{
  late MusicServices _musicServices;
  final isContentFetched = false.obs;
  late List<dynamic> _homeContentList;
HomeScreenController(){
  _init();
}

Future<void> _init() async {
  _musicServices = MusicServices();
  _homeContentList = await _musicServices.getHome(limit: 5);
  isContentFetched.value = true;
}

List<Song> get quickPicksSongList{
  print('hello');
  print(_homeContentList[0]['contents'][0]["thumbnails"][1]["url"]);
  return (_homeContentList[0]['contents']).map<Song>((item)=>Song.fromJson(item)).toList();
}

void getRelatedArtist(){
   SongStreamUrlService(song: quickPicksSongList[0]).songStreamUrl;
}



}