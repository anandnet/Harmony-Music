import 'dart:developer';

import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../models/song.dart';

class HomeLibrayController extends GetxController{
  late RxList<Song> cachedSongsList = RxList();
  final isSongFetched = false.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init(){
    //TODO verify from cached directory if song exist or not
    final box = Hive.box("cacheSongs");
     cachedSongsList.value = box.values.map<Song?>((song) => song as Song).whereType<Song>().toList();
     inspect(cachedSongsList.value);
     isSongFetched.value =true;
  }
}